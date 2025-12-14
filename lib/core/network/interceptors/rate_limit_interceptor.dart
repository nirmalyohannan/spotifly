import 'dart:async';
import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:spotifly/core/utils/logger.dart';

class RateLimitInterceptor extends Interceptor {
  final int maxRequests;
  final Duration interval;
  final Queue<DateTime> _timestamps = Queue();
  DateTime? _retryAfterTime;

  final Dio? client;

  RateLimitInterceptor({
    this.maxRequests = 2,
    this.interval = const Duration(seconds: 1),
    this.client,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // If a global retry-after is active, wait for it to expire
    if (_retryAfterTime != null) {
      final now = DateTime.now();
      if (now.isBefore(_retryAfterTime!)) {
        final diff = _retryAfterTime!.difference(now);
        Logger.apiRequest(
          options,
          message: 'Rate limit (429) active. Waiting ${diff.inMilliseconds}ms ',
        );
        await Future.delayed(diff);
      }
    }

    // Client-side rate limiting (requests per second)
    while (_timestamps.length >= maxRequests) {
      final diff = DateTime.now().difference(_timestamps.first);
      if (diff < interval) {
        Logger.apiRequest(
          options,
          message:
              'Client rate limit. Waiting ${(interval - diff).inMilliseconds}ms',
        );
        await Future.delayed(interval - diff);
      }

      // Remove timestamps that are older than the interval
      while (_timestamps.isNotEmpty &&
          DateTime.now().difference(_timestamps.first) >= interval) {
        _timestamps.removeFirst();
      }
    }

    _timestamps.add(DateTime.now());
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 429) {
      final retryAfterString = err.response?.headers.value('retry-after');
      final retryAfterSeconds = int.tryParse(retryAfterString ?? '0') ?? 5;
      final duration = Duration(seconds: retryAfterSeconds);

      _retryAfterTime = DateTime.now().add(duration);

      Logger.e('Received 429. Retrying after $retryAfterSeconds seconds.');
      await Future.delayed(duration);

      try {
        // Retry the request with a new Dio instance to avoid circular dependency issues
        // and ensure we rely on the options from the original request.
        final dio = client ?? Dio();
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // If the retry also fails, propagate the error (or the original one)
        if (e is DioException) {
          return handler.next(e);
        }
      }
    }
    handler.next(err);
  }
}
