import 'package:spotifly/core/services/spotify_auth_service.dart';
import 'package:spotifly/features/home/domain/repositories/home_repository.dart';
import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';

class LogoutUser {
  final SpotifyAuthService authService;
  final PlaylistRepository playlistRepository;
  final HomeRepository homeRepository;

  LogoutUser({
    required this.authService,
    required this.playlistRepository,
    required this.homeRepository,
  });

  Future<void> call() async {
    await authService.logout();
    await playlistRepository.clearCache();
    homeRepository.clearCache();
  }
}
