import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';

class AddSongToLiked {
  final PlaylistRepository repository;

  AddSongToLiked(this.repository);

  Future<void> call(String songId) async {
    return repository.addSongToLiked(songId);
  }
}
