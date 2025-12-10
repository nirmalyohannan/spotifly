import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:spotifly/core/network/interceptors/rate_limit_interceptor.dart';
import 'package:spotifly/core/services/spotify_auth_service.dart';

class SpotifyApiClient {
  final SpotifyAuthService _authService;
  late final Dio _dio;
  static const String _baseUrl = 'https://api.spotify.com/v1';

  SpotifyApiClient(this._authService) {
    _dio = Dio(
      BaseOptions(baseUrl: _baseUrl, validateStatus: (status) => true),
    );
    _dio.interceptors.add(
      RateLimitInterceptor(
        maxRequests: 2,
        interval: const Duration(seconds: 1),
      ),
    );
  }

  Future<Response> get(String endpoint) async {
    logRequest(endpoint: endpoint, method: 'GET');
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    var response = await _dio.get(
      endpoint,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 401) {
      // Token might be expired, try one more time after refresh (getAccessToken handles refresh)
      final newToken = await _authService.getAccessToken();
      if (newToken != null) {
        response = await _dio.get(
          endpoint,
          options: Options(headers: {'Authorization': 'Bearer $newToken'}),
        );
      }
    }

    return response;
  }

  Future<dynamic> getJson(String endpoint) async {
    logRequest(endpoint: endpoint, method: 'GET_JSON');
    final response = await get(endpoint);
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      // Dio handles JSON decoding automatically
      return response.data;
    } else {
      throw Exception(
        'Failed to load data: ${response.statusCode} ${response.data}',
      );
    }
  }

  Future<Response> put(String endpoint, {dynamic body}) async {
    logRequest(endpoint: endpoint, method: 'PUT', body: body);
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    var response = await _dio.put(
      endpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
      data: body,
    );

    if (response.statusCode == 401) {
      final newToken = await _authService.getAccessToken();
      if (newToken != null) {
        response = await _dio.put(
          endpoint,
          options: Options(
            headers: {
              'Authorization': 'Bearer $newToken',
              'Content-Type': 'application/json',
            },
          ),
          data: body,
        );
      }
    }
    return response;
  }

  Future<Response> delete(String endpoint, {dynamic body}) async {
    logRequest(endpoint: endpoint, method: 'DELETE', body: body);
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    var response = await _dio.delete(
      endpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
      data: body,
    );

    if (response.statusCode == 401) {
      final newToken = await _authService.getAccessToken();
      if (newToken != null) {
        response = await _dio.delete(
          endpoint,
          options: Options(
            headers: {
              'Authorization': 'Bearer $newToken',
              'Content-Type': 'application/json',
            },
          ),
          data: body,
        );
      }
    }
    return response;
  }

  void logRequest({
    required String endpoint,
    required String method,
    dynamic body,
  }) {
    var time = DateTime.now();
    var formattedTime =
        '${time.hour}:${time.minute}:${time.second}.${time.millisecond}';
    log('$formattedTime | $method | $endpoint');
  }
}
