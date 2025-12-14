import '../../../../shared/domain/repositories/playlist_repository.dart';

class SyncPlaylistAndSongs {
  final PlaylistRepository repository;

  SyncPlaylistAndSongs(this.repository);

  Future<void> call() async {
    return repository.syncPlaylistAndSongs();
  }
}
