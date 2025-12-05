import '../entities/playlist.dart';
import '../entities/song.dart';

abstract class PlaylistRepository {
  Future<List<Playlist>> getPlaylists();
  Future<List<Song>> getLikedSongs();
  Future<Playlist?> getPlaylistById(String id);
  Future<String?> getUserProfileImage();
}
