import '../../../../shared/domain/entities/song.dart';
import '../../../../shared/domain/repositories/playlist_repository.dart';

class GetLikedSongs {
  final PlaylistRepository repository;

  GetLikedSongs(this.repository);

  Future<List<Song>> call({
    int offset = 0,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    return repository.getLikedSongs(
      offset: offset,
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }

  List<Song> getCached() {
    return repository.getCachedLikedSongs();
  }
}
