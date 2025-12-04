import 'package:get_it/get_it.dart';
import 'package:spotifly/core/network/spotify_api_client.dart';
import 'package:spotifly/core/services/spotify_auth_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<SpotifyAuthService>(() => SpotifyAuthService());
  getIt.registerLazySingleton<SpotifyApiClient>(
    () => SpotifyApiClient(getIt<SpotifyAuthService>()),
  );
}
