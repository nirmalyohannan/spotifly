import 'package:get_it/get_it.dart';
import 'package:spotifly/core/network/spotify_api_client.dart';
import 'package:spotifly/core/services/spotify_auth_service.dart';
import 'package:spotifly/features/player/data/datasources/youtube_remote_data_source.dart';
import 'package:spotifly/features/player/data/repositories/player_repository_impl.dart';
import 'package:spotifly/features/player/domain/repositories/player_repository.dart';
import 'package:spotifly/features/player/domain/usecases/get_audio_stream.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';
import 'package:spotifly/shared/data/repositories/playlist_repository_impl.dart';
import 'package:spotifly/features/home/domain/repositories/home_repository.dart';
import 'package:spotifly/features/home/data/repositories/home_repository_impl.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<SpotifyAuthService>(() => SpotifyAuthService());
  getIt.registerLazySingleton<SpotifyApiClient>(
    () => SpotifyApiClient(getIt<SpotifyAuthService>()),
  );

  // Player Feature
  getIt.registerLazySingleton<YoutubeExplode>(() => YoutubeExplode());
  getIt.registerLazySingleton<YoutubeRemoteDataSource>(
    () => YoutubeRemoteDataSourceImpl(getIt<YoutubeExplode>()),
  );
  getIt.registerLazySingleton<PlayerRepository>(
    () => PlayerRepositoryImpl(getIt<YoutubeRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetAudioStream>(
    () => GetAudioStream(getIt<PlayerRepository>()),
  );

  // Library Feature
  getIt.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(),
  );

  // Home Feature
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());
}
