import 'package:spotifly/shared/domain/entities/playlist.dart';
import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';

class GetPlaylistById {
  final PlaylistRepository playlistRepository;

  GetPlaylistById(this.playlistRepository);

  Future<Playlist?> call(String id) {
    return playlistRepository.getPlaylistById(id);
  }
}
