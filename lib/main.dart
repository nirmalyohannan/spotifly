import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:spotifly/shared/data/models/hive_song.dart';
import 'package:spotifly/shared/data/models/hive_playlist.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/di/service_locator.dart';
import 'package:audio_service/audio_service.dart';
import 'package:spotifly/core/services/spotify_auth_service.dart';
import 'package:spotifly/features/auth/presentation/pages/login_page.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/domain/usecases/add_song_to_liked.dart';
import 'package:spotifly/features/player/domain/usecases/remove_song_from_liked.dart';
import 'package:spotifly/features/player/domain/usecases/is_song_liked.dart';
import 'package:spotifly/core/theme/app_theme.dart';
import 'package:spotifly/features/shell/presentation/pages/main_shell.dart';
import 'package:spotifly/features/library/domain/use_cases/load_playlists_with_sync.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HiveSongAdapter());
  Hive.registerAdapter(HivePlaylistAdapter());

  await setupServiceLocator();

  final authService = getIt<SpotifyAuthService>();
  final token = await authService.getAccessToken();

  if (token != null) {
    getIt<LoadPlaylistsWithSync>().call();
  }

  runApp(
    BlocProvider(
      create: (context) => PlayerBloc(
        audioHandler: getIt<AudioHandler>(),
        addSongToLiked: getIt<AddSongToLiked>(),
        removeSongFromLiked: getIt<RemoveSongFromLiked>(),
        isSongLiked: getIt<IsSongLiked>(),
      ),
      child: SpotiFlyApp(initialRoute: token != null ? '/' : '/login'),
    ),
  );
}

class SpotiFlyApp extends StatelessWidget {
  final String initialRoute;

  const SpotiFlyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpotiFly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const MainShell(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
