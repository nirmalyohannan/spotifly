import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';

abstract class PlaylistRepository {
  Future<int> getLikedSongsCount();

  Future<List<Playlist>> getPlaylists();
  Future<List<Playlist>> getCachedPlaylists();
  Future<List<Playlist>> refreshPlaylists();

  ///Playlist with full songs loaded
  ///If snapshotId is provided, it will try to get from cache first if snapshotId matches
  ///If snapshotId is not provided, it will try to get from remote
  Future<Playlist?> getPlaylistById(String id, String? snapshotId);

  Future<String?> getUserProfileImage();

  Future<void> addSongToLiked(Song song);
  Future<void> removeSongFromLiked(String songId);
  Future<bool> isSongLiked(String songId);

  Future<List<Song>> getLikedSongs();

  Stream<List<Song>> get likedSongsStream;
  void clearCache();

  Future<void> syncLibrary();
}
