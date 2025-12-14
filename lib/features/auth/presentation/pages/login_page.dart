import 'package:flutter/material.dart';
import 'package:spotifly/core/services/spotify_auth_service.dart';

import 'package:spotifly/core/di/service_locator.dart';
import 'package:spotifly/features/library/domain/use_cases/load_playlists_with_sync.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final SpotifyAuthService _authService = SpotifyAuthService();

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final success = await _authService.authenticate();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Trigger library sync on successful login
        getIt<LoadPlaylistsWithSync>().call();

        Navigator.of(context).pushReplacementNamed('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const Icon(Icons.music_note, size: 100, color: Color(0xFF1DB954)),
            const SizedBox(height: 32),
            const Text(
              'SpotiFly',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Millions of songs.\nFree on SpotiFly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 48),
            if (_isLoading)
              const CircularProgressIndicator(color: Color(0xFF1DB954))
            else
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'LOG IN WITH SPOTIFY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
