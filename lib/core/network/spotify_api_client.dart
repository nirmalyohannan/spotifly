import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotifly/core/services/spotify_auth_service.dart';

class SpotifyApiClient {
  final SpotifyAuthService _authService;
  final http.Client _client = http.Client();
  static const String _baseUrl = 'https://api.spotify.com/v1';

  SpotifyApiClient(this._authService);

  Future<http.Response> get(String endpoint) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await _client.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      // Token might be expired, try one more time after refresh (getAccessToken handles refresh)
      final newToken = await _authService.getAccessToken();
      if (newToken != null) {
        return await _client.get(
          Uri.parse('$_baseUrl$endpoint'),
          headers: {'Authorization': 'Bearer $newToken'},
        );
      }
    }

    return response;
  }

  Future<dynamic> getJson(String endpoint) async {
    final response = await get(endpoint);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to load data: ${response.statusCode} ${response.body}',
      );
    }
  }
}
