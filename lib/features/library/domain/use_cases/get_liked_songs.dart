import '../../../../shared/domain/entities/song.dart';
import '../../../../shared/domain/repositories/playlist_repository.dart';

class GetLikedSongs {
  final PlaylistRepository repository;

  GetLikedSongs(this.repository);

  Stream<List<Song>> get stream => repository.likedSongsStream;
}
