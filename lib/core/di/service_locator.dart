import 'package:get_it/get_it.dart';
import 'package:spotifly/core/network/spotify_api_client.dart';
import 'package:spotifly/core/services/spotify_auth_service.dart';
import 'package:spotifly/features/player/data/datasources/audio_remote_data_source.dart';
import 'package:spotifly/features/player/data/datasources/youtube_audio_source.dart';
import 'package:spotifly/features/player/data/repositories/player_repository_impl.dart';
import 'package:spotifly/features/player/domain/repositories/player_repository.dart';
import 'package:spotifly/features/player/domain/usecases/get_audio_stream.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<SpotifyAuthService>(() => SpotifyAuthService());
  getIt.registerLazySingleton<SpotifyApiClient>(
    () => SpotifyApiClient(getIt<SpotifyAuthService>()),
  );

  // Player Feature
  getIt.registerLazySingleton<YoutubeExplode>(() => YoutubeExplode());
  getIt.registerLazySingleton<AudioRemoteDataSource>(
    () => YoutubeAudioSource(getIt<YoutubeExplode>()),
  );
  getIt.registerLazySingleton<PlayerRepository>(
    () => PlayerRepositoryImpl(getIt<AudioRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetAudioStream>(
    () => GetAudioStream(getIt<PlayerRepository>()),
  );
}
