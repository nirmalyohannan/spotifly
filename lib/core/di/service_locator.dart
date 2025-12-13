import 'package:get_it/get_it.dart';
import 'package:spotifly/shared/data/data_sources/playlist_local_data_source.dart';
import 'package:spotifly/shared/data/data_sources/playlist_remote_data_source.dart';
import 'package:spotifly/core/network/spotify_api_client.dart';
import 'package:spotifly/core/services/spotify_auth_service.dart';
import 'package:spotifly/features/player/data/datasources/youtube_remote_data_source.dart';
import 'package:spotifly/features/player/data/repositories/player_repository_impl.dart';
import 'package:spotifly/features/player/domain/repositories/player_repository.dart';
import 'package:spotifly/features/player/domain/usecases/get_audio_stream.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:audio_service/audio_service.dart';
import 'package:spotifly/core/services/audio_player_handler.dart';
import 'package:spotifly/features/player/domain/usecases/add_song_to_liked.dart';
import 'package:spotifly/features/player/domain/usecases/remove_song_from_liked.dart';
import 'package:spotifly/features/player/domain/usecases/is_song_liked.dart';
import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';
import 'package:spotifly/shared/data/repositories/playlist_repository_impl.dart';
import 'package:spotifly/features/home/domain/repositories/home_repository.dart';
import 'package:spotifly/features/home/data/repositories/home_repository_impl.dart';
import 'package:spotifly/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:spotifly/features/settings/domain/repositories/settings_repository.dart';
import 'package:spotifly/features/settings/domain/usecases/get_user_profile.dart';
import 'package:spotifly/features/settings/domain/usecases/logout_user.dart';
import 'package:spotifly/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:spotifly/features/library/domain/use_cases/get_liked_songs.dart';
import 'package:spotifly/features/library/domain/use_cases/get_liked_songs_count.dart';
import 'package:spotifly/features/library/presentation/bloc/liked_songs_bloc/liked_songs_bloc.dart';
import 'package:spotifly/features/player/data/repositories/audio_cache_repository_impl.dart';
import 'package:spotifly/features/player/domain/repositories/audio_cache_repository.dart';
import 'package:hive_ce/hive.dart';
import 'package:spotifly/features/player/domain/entities/cache_source.dart';
import 'package:spotifly/features/player/data/models/cached_song_metadata.dart';
import 'package:spotifly/features/settings/domain/usecases/clear_audio_cache.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Initialize Hive Adapters for Caching
  Hive.registerAdapter(CacheSourceAdapter());
  Hive.registerAdapter(CachedSongMetadataAdapter());

  getIt.registerLazySingleton<SpotifyAuthService>(() => SpotifyAuthService());
  getIt.registerLazySingleton<SpotifyApiClient>(
    () => SpotifyApiClient(getIt<SpotifyAuthService>()),
  );

  getIt.registerLazySingleton<YoutubeExplode>(() => YoutubeExplode());
  getIt.registerLazySingleton<YoutubeRemoteDataSource>(
    () => YoutubeRemoteDataSourceImpl(getIt<YoutubeExplode>()),
  );
  getIt.registerLazySingleton<PlayerRepository>(
    () => PlayerRepositoryImpl(getIt<YoutubeRemoteDataSource>()),
  );
  getIt.registerLazySingleton<AudioCacheRepository>(
    () => AudioCacheRepositoryImpl(),
  );
  getIt.registerLazySingleton<GetAudioStream>(
    () => GetAudioStream(getIt<PlayerRepository>()),
  );
  getIt.registerLazySingleton<AddSongToLiked>(
    () => AddSongToLiked(getIt<PlaylistRepository>()),
  );
  getIt.registerLazySingleton<RemoveSongFromLiked>(
    () => RemoveSongFromLiked(getIt<PlaylistRepository>()),
  );
  getIt.registerLazySingleton<IsSongLiked>(
    () => IsSongLiked(getIt<PlaylistRepository>()),
  );

  // Library Feature
  getIt.registerLazySingleton<PlaylistLocalDataSource>(
    () => PlaylistLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<PlaylistRemoteDataSource>(
    () => PlaylistRemoteDataSourceImpl(getIt<SpotifyApiClient>()),
  );
  getIt.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(
      getIt<PlaylistRemoteDataSource>(),
      getIt<PlaylistLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<GetLikedSongs>(
    () => GetLikedSongs(getIt<PlaylistRepository>()),
  );
  getIt.registerLazySingleton<GetLikedSongsCount>(
    () => GetLikedSongsCount(getIt<PlaylistRepository>()),
  );
  getIt.registerFactory<LikedSongsBloc>(
    () => LikedSongsBloc(
      getLikedSongs: getIt<GetLikedSongs>(),
      getLikedSongsCount: getIt<GetLikedSongsCount>(),
    ),
  );

  // Home Feature
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());

  // Player Feature - AudioHandler (Must be registered after Repositories, required for Android Auto)
  final audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(
      getIt<HomeRepository>(),
      getIt<PlaylistRepository>(),
      getIt<PlayerRepository>(),
      getIt<AudioCacheRepository>(),
    ),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.spotifly.channel.audio',
      androidNotificationChannelName: 'SpotiFly Audio',
      androidNotificationOngoing: true,
    ),
  );
  getIt.registerSingleton<AudioHandler>(audioHandler);

  // Settings Feature
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(),
  );
  getIt.registerLazySingleton<GetUserProfile>(
    () => GetUserProfile(getIt<SettingsRepository>()),
  );
  getIt.registerLazySingleton<LogoutUser>(
    () => LogoutUser(
      authService: getIt<SpotifyAuthService>(),
      playlistRepository: getIt<PlaylistRepository>(),
      homeRepository: getIt<HomeRepository>(),
    ),
  );
  getIt.registerLazySingleton<ClearAudioCache>(
    () => ClearAudioCache(getIt<AudioCacheRepository>()),
  );
  getIt.registerFactory<SettingsBloc>(
    () => SettingsBloc(
      getUserProfile: getIt<GetUserProfile>(),
      logoutUser: getIt<LogoutUser>(),
      clearAudioCache: getIt<ClearAudioCache>(),
    ),
  );
}
