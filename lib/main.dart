import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/di/service_locator.dart';
import 'package:spotifly/core/services/spotify_auth_service.dart';
import 'package:spotifly/features/auth/presentation/pages/login_page.dart';
import 'package:spotifly/features/player/domain/usecases/get_audio_stream.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/core/theme/app_theme.dart';
import 'package:spotifly/features/shell/presentation/pages/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();

  final authService = getIt<SpotifyAuthService>();
  final token = await authService.getAccessToken();

  runApp(
    BlocProvider(
      create: (context) => PlayerBloc(getAudioStream: getIt<GetAudioStream>()),
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
