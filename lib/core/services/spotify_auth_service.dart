import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:spotifly/credentials.dart';

class SpotifyAuthService {
  static const String _clientId = Credentials.clientId;
  static const String _clientSecret = Credentials.clientSecret;
  static const String _redirectUri = Credentials.redirectUri;
  static const String _scope =
      'user-read-private user-read-email playlist-read-private playlist-read-collaborative user-library-read user-top-read user-read-recently-played playlist-modify-public playlist-modify-private user-library-modify';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> authenticate() async {
    try {
      // Generate a random state string for security
      final state = _generateRandomString(16);

      // Construct the authorization URL
      final url = Uri.https('accounts.spotify.com', '/authorize', {
        'response_type': 'code',
        'client_id': _clientId,
        'scope': _scope,
        'redirect_uri': _redirectUri,
        'state': state,
      });

      // Present the web page to the user
      final result = await FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: 'spotifly',
      );

      // Extract the code from the result URL
      final code = Uri.parse(result).queryParameters['code'];

      if (code != null) {
        return await _exchangeCodeForToken(code);
      }
      return false;
    } catch (e) {
      dev.log('Error authenticating: $e');
      return false;
    }
  }

  Future<bool> _exchangeCodeForToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': _redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(
          data['access_token'],
          data['refresh_token'],
          data['expires_in'],
        );
        return true;
      } else {
        dev.log('Failed to exchange code: ${response.body}');
        return false;
      }
    } catch (e) {
      dev.log('Error exchanging code: $e');
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    final expiryStr = await _storage.read(key: 'expires_at');
    if (expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry)) {
        await _refreshToken();
      }
    }
    return await _storage.read(key: 'access_token');
  }

  Future<void> _refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return;

    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'refresh_token', 'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Refresh token might not be returned if it hasn't changed
        final newRefreshToken = data['refresh_token'] ?? refreshToken;
        await _saveTokens(
          data['access_token'],
          newRefreshToken,
          data['expires_in'],
        );
      }
    } catch (e) {
      dev.log('Error refreshing token: $e');
    }
  }

  Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
    int expiresIn,
  ) async {
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn - 60));
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    await _storage.write(key: 'expires_at', value: expiresAt.toIso8601String());
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  String _generateRandomString(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }
}
