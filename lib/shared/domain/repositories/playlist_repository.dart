import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';

abstract class PlaylistRepository {
  Future<int> getLikedSongsCount();

  ///Syncs playlists and songs
  ///Yields the List of Playlists from cache as soon as possible
  ///Yields the List of Playlists from remote when it is available
  ///and updates the cache of each playlist's List of Songs in background
  ///If skipCachingPlaylistSongs is true, cache of each playlist's List of Songs will not be updated
  ///This can be used when updating a Playlist's Songs is not required
  ///Caution: The Playlist's snapshotId will be updated without fetching the songs (Use when necessary)
  Stream<List<Playlist>> loadPlaylistsWithSync({
    bool skipCachingPlaylistSongs = false,
  });

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

  Future<void> addSongToPlaylist(String playlistId, Song song);
  Future<void> removeSongFromPlaylist(String playlistId, String songId);
}
