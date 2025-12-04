import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/application/bloc/player_bloc.dart';
import 'package:spotifly/core/theme/app_theme.dart';
import 'package:spotifly/presentation/widgets/main_shell.dart';

void main() {
  runApp(
    BlocProvider(create: (context) => PlayerBloc(), child: const SpotiFlyApp()),
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
