import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';

class RemoveSongFromLiked {
  final PlaylistRepository repository;

  RemoveSongFromLiked(this.repository);

  Future<void> call(String songId) async {
    return repository.removeSongFromLiked(songId);
  }
}
