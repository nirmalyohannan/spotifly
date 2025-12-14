import '../../../../shared/domain/entities/playlist.dart';
import '../../../../shared/domain/repositories/playlist_repository.dart';

class LoadPlaylistsWithSync {
  final PlaylistRepository repository;

  LoadPlaylistsWithSync(this.repository);

  Future<Stream<List<Playlist>>> call() async {
    return repository.loadPlaylistsWithSync();
  }
}
