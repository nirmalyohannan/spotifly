import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotifly/core/theme/app_theme.dart';
import 'package:spotifly/presentation/widgets/main_shell.dart';
import 'package:spotifly/presentation/providers/player_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PlayerProvider())],
      child: const SpotiFlyApp(),
    ),
  );
}

class SpotiFlyApp extends StatelessWidget {
  const SpotiFlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpotiFly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}
