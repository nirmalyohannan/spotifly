import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';

abstract class PlaylistRepository {
  Future<List<Song>> getLikedSongs({int offset = 0, int limit = 20});
  Future<int> getLikedSongsCount();
  Future<List<Playlist>> getPlaylists();
  Future<Playlist?> getPlaylistById(String id);
  Future<String?> getUserProfileImage();
  Future<void> addSongToLiked(String songId);
  Future<void> removeSongFromLiked(String songId);
  Future<bool> isSongLiked(String songId);
  void clearCache();
}
