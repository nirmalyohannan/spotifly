import '../../../../shared/domain/entities/song.dart';
import '../../../../shared/domain/repositories/playlist_repository.dart';

class GetLikedSongs {
  final PlaylistRepository repository;

  GetLikedSongs(this.repository);

  List<Song> getCached() {
    return repository.getCachedLikedSongs();
  }

  Stream<List<Song>> get stream => repository.likedSongsStream;
}
