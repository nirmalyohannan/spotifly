import 'package:spotifly/shared/domain/entities/song.dart';
import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';

class AddSongToLiked {
  final PlaylistRepository repository;

  AddSongToLiked(this.repository);

  Future<void> call(Song song) async {
    return repository.addSongToLiked(song);
  }
}
