import 'package:spotifly/shared/domain/entities/song.dart';
import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';

class GetPlaylistSongs {
  final PlaylistRepository playlistRepository;

  GetPlaylistSongs(this.playlistRepository);

  Future<List<Song>> call(String id, String snapshotId) {
    return playlistRepository.getPlaylistSongs(id, snapshotId);
  }
}
