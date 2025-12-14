import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';

abstract class PlaylistRepository {
  Future<int> getLikedSongsCount();

  ///Syncs playlists and songs
  ///Yields the List of Playlists from cache as soon as possible
  ///Yields the List of Playlists from remote when it is available
  ///and updates the cache of each playlist's List of Songs in background
  Stream<List<Playlist>> loadPlaylistsWithSync();

  ///Playlist with full songs loaded
  ///If snapshotId is provided, it will try to get from cache first if snapshotId matches
  ///If snapshotId is not provided, it will try to get from remote
  Future<List<Song>> getPlaylistSongs(String id, String? snapshotId);

  Future<String?> getUserProfileImage();

  Future<void> addSongToLiked(Song song);
  Future<void> removeSongFromLiked(String songId);
  Future<bool> isSongLiked(String songId);

  Future<List<Song>> getLikedSongs();

  Stream<List<Song>> get likedSongsStream;
  Future<void> clearCache();
}
