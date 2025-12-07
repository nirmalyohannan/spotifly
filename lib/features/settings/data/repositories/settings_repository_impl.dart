import 'package:spotifly/core/di/service_locator.dart';
import 'package:spotifly/core/network/spotify_api_client.dart';
import 'package:spotifly/features/settings/domain/entities/user_profile.dart';
import 'package:spotifly/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SpotifyApiClient _apiClient = getIt<SpotifyApiClient>();

  @override
  Future<UserProfile> getProfile() async {
    final data = await _apiClient.getJson('/me');

    String? imageUrl;
    final images = data['images'] as List;
    if (images.isNotEmpty) {
      imageUrl = images.first['url'] as String;
    }

    return UserProfile(
      id: data['id'],
      displayName: data['display_name'],
      email: data['email'],
      country: data['country'],
      product: data['product'], // 'premium', 'free', etc.
      imageUrl: imageUrl,
    );
  }
}
