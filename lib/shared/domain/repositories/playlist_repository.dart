import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';

abstract class PlaylistRepository {
  Future<int> getLikedSongsCount();

  Future<List<Playlist>> getPlaylists();
  Future<Playlist?> getPlaylistById(String id);

  Future<String?> getUserProfileImage();

  Future<void> addSongToLiked(Song song);
  Future<void> removeSongFromLiked(String songId);
  Future<bool> isSongLiked(String songId);

  Stream<List<Song>> get likedSongsStream;
  void clearCache();
}
