import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotifly/core/network/interceptors/rate_limit_interceptor.dart';

// Fake Dio Adapter to avoid real network calls
class FakeAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('RateLimitInterceptor', () {
    late Dio dio;
    late RateLimitInterceptor rateLimitInterceptor;

    setUp(() {
      dio = Dio();
      dio.httpClientAdapter = FakeAdapter();
      rateLimitInterceptor = RateLimitInterceptor(
        maxRequests: 2,
        interval: const Duration(seconds: 1),
      );
      dio.interceptors.add(rateLimitInterceptor);
    });

    test('should allow 2 requests immediately', () async {
      final start = DateTime.now();
      await Future.wait([dio.get('/test'), dio.get('/test')]);
      final end = DateTime.now();
      final duration = end.difference(start);

      // Should be very fast, less than 500ms
      expect(duration.inMilliseconds, lessThan(500));
    });

    test('should delay 3rd request', () async {
      final start = DateTime.now();
      await Future.wait([dio.get('/test'), dio.get('/test'), dio.get('/test')]);
      final end = DateTime.now();
      final duration = end.difference(start);

      // The 3rd request should wait until 1 second passes from the 1st request.
      expect(duration.inMilliseconds, greaterThanOrEqualTo(900));
    });

    test('should delay 5 requests appropriately', () async {
      final start = DateTime.now();
      // 5 requests:
      // 1: 0ms
      // 2: 0ms
      // 3: 1000ms (approx)
      // 4: 1000ms (approx)
      // 5: 2000ms (approx)

      await Future.wait([
        dio.get('/test'),
        dio.get('/test'),
        dio.get('/test'),
        dio.get('/test'),
        dio.get('/test'),
      ]);
      final end = DateTime.now();
      final duration = end.difference(start);

      expect(duration.inMilliseconds, greaterThanOrEqualTo(1900));
    });
  });
}
