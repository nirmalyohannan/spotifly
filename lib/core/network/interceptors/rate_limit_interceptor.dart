import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:dio/dio.dart';

class RateLimitInterceptor extends Interceptor {
  final int maxRequests;
  final Duration interval;
  final Queue<DateTime> _timestamps = Queue();

  RateLimitInterceptor({
    this.maxRequests = 2,
    this.interval = const Duration(seconds: 1),
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    while (_timestamps.length >= maxRequests) {
      final diff = DateTime.now().difference(_timestamps.first);
      if (diff < interval) {
        var endpoint = options.path;
        var method = options.method;
        log(
          'Rate limit. Waiting ${(interval - diff).inMilliseconds}s for $method $endpoint',
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
}
