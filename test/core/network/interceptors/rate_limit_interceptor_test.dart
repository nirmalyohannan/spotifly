import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotifly/core/network/interceptors/rate_limit_interceptor.dart';

class FakeDio extends Fake implements Dio {
  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) async {
    return Response(
      requestOptions: requestOptions,
      statusCode: 200,
      data: {'data': 'retried_ok'} as T,
    );
  }
}

class MockAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;

  MockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late FakeDio retryDio;
  late RateLimitInterceptor rateLimitInterceptor;

  setUp(() {
    dio = Dio();
    retryDio = FakeDio();

    rateLimitInterceptor = RateLimitInterceptor(
      maxRequests: 5,
      interval: const Duration(milliseconds: 100),
      client: retryDio,
    );

    dio.interceptors.add(rateLimitInterceptor);
  });

  test('should allow requests within limit', () async {
    dio.httpClientAdapter = MockAdapter((options) async {
      return ResponseBody.fromString(
        jsonEncode({'data': 'ok'}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    final response = await dio.get('/test');
    expect(response.statusCode, 200);
    expect(response.data['data'], 'ok');
  });

  test('should retry on 429', () async {
    dio.httpClientAdapter = MockAdapter((options) async {
      return ResponseBody.fromString(
        jsonEncode({'error': 'Too Many Requests'}),
        429,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
          'retry-after': ['1'],
        },
      );
    });

    final stopwatch = Stopwatch()..start();
    final response = await dio.get('/retry-test');
    stopwatch.stop();

    expect(response.statusCode, 200);
    expect(response.data['data'], 'retried_ok');
    expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1000));
  });

  test('should pause subsequent requests while 429 is active', () async {
    dio.httpClientAdapter = MockAdapter((options) async {
      if (options.path.contains('trigger-429')) {
        return ResponseBody.fromString(
          '',
          429,
          headers: {
            'retry-after': ['2'],
          },
        );
      }
      return ResponseBody.fromString(jsonEncode({}), 200);
    });

    final futureA = dio.get('/trigger-429');

    await Future.delayed(const Duration(milliseconds: 100));

    final stopwatchB = Stopwatch()..start();
    final futureB = dio.get('/delayed');

    await Future.wait([futureA, futureB]);
    stopwatchB.stop();

    // B should have waited roughly remainder of 2s (1900ms)
    expect(stopwatchB.elapsedMilliseconds, greaterThanOrEqualTo(1000));
  });
}
