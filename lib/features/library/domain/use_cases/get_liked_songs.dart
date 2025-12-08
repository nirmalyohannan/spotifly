import '../../../../shared/domain/entities/song.dart';
import '../../../../shared/domain/repositories/playlist_repository.dart';

class GetLikedSongs {
  final PlaylistRepository repository;

  GetLikedSongs(this.repository);

  Future<List<Song>> call({int offset = 0, int limit = 20}) async {
    return await repository.getLikedSongs(offset: offset, limit: limit);
  }
}
