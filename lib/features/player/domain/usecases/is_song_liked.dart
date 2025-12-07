import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';

class IsSongLiked {
  final PlaylistRepository repository;

  IsSongLiked(this.repository);

  Future<bool> call(String songId) async {
    return repository.isSongLiked(songId);
  }
}
