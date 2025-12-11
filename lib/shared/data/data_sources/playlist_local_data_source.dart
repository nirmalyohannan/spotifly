import 'package:hive_ce/hive.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/playlist.dart';
import '../models/hive_song.dart';
import '../models/hive_playlist.dart';

abstract class PlaylistLocalDataSource {
  Future<List<Song>> getLikedSongs();
  Future<void> cacheLikedSongs(List<Song> songs);
  Future<void> addSongToLiked(Song song);
  Future<void> removeSongFromLiked(String songId);

  Future<int?> getLikedSongsCount();
  Future<void> cacheLikedSongsCount(int count);

  Future<bool> getNeedsRefresh();
  Future<void> setNeedsRefresh(bool value);

  Future<void> cacheUserPlaylists(List<Playlist> playlists);
  Future<List<Playlist>> getUserPlaylists();

  Future<void> cachePlaylistSongs(String playlistId, List<Song> songs);
  Future<List<Song>> getPlaylistSongs(String playlistId);

  // We can store snapshotId in the playlist object itself in the list,
  // but we might need a quick lookup or just rely on the list.
  // Actually, cacheUserPlaylists stores HivePlaylists which have snapshotId.
}

class PlaylistLocalDataSourceImpl implements PlaylistLocalDataSource {
  static const String _boxName = 'liked_songs_box';
  static const String _keyLikedSongs = 'liked_songs';
  static const String _keyCount = 'liked_songs_count';
  static const String _keyNeedsRefresh = 'needs_refresh';

  Box? _box;

  Future<Box> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(_boxName);
    return _box!;
  }

  @override
  Future<List<Song>> getLikedSongs() async {
    final b = await box;
    // We store the list as a List<HiveSong>
    // However, Hive might return dynamic.
    final dynamic data = b.get(_keyLikedSongs);
    if (data != null && data is List) {
      return data.cast<HiveSong>().map((e) => e.toDomain()).toList();
    }
    return [];
  }

  @override
  Future<void> cacheLikedSongs(List<Song> songs) async {
    final b = await box;
    final hiveSongs = songs.map((s) => HiveSong.fromDomain(s)).toList();
    await b.put(_keyLikedSongs, hiveSongs);
  }

  @override
  Future<void> addSongToLiked(Song song) async {
    // We might want to optimize this to not read the full list if possible,
    // but Hive objects are in memory if box is open.
    // For simplicity and to ensure consistency with the repository logic,
    // we can just read, modify, write or let repository handle the full list update.
    // But repository logic was: get cached, insert, update.
    // Let's implement helper method here.
    final currentList = await getLikedSongs();
    if (!currentList.any((s) => s.id == song.id)) {
      currentList.insert(0, song);
      await cacheLikedSongs(currentList);
    }
  }

  @override
  Future<void> removeSongFromLiked(String songId) async {
    final currentList = await getLikedSongs();
    currentList.removeWhere((s) => s.id == songId);
    await cacheLikedSongs(currentList);
  }

  @override
  Future<int?> getLikedSongsCount() async {
    final b = await box;
    return b.get(_keyCount) as int?;
  }

  @override
  Future<void> cacheLikedSongsCount(int count) async {
    final b = await box;
    await b.put(_keyCount, count);
  }

  @override
  Future<bool> getNeedsRefresh() async {
    final b = await box;
    return b.get(_keyNeedsRefresh, defaultValue: false) as bool;
  }

  @override
  Future<void> setNeedsRefresh(bool value) async {
    final b = await box;
    await b.put(_keyNeedsRefresh, value);
  }

  @override
  Future<void> cacheUserPlaylists(List<Playlist> playlists) async {
    final b = await box;
    final hivePlaylists = playlists
        .map((p) => HivePlaylist.fromDomain(p))
        .toList();
    await b.put('user_playlists', hivePlaylists);
  }

  @override
  Future<List<Playlist>> getUserPlaylists() async {
    final b = await box;
    final dynamic data = b.get('user_playlists');
    if (data != null && data is List) {
      return data.cast<HivePlaylist>().map((e) => e.toDomain()).toList();
    }
    return [];
  }

  @override
  Future<void> cachePlaylistSongs(String playlistId, List<Song> songs) async {
    final b = await box;
    final hiveSongs = songs.map((s) => HiveSong.fromDomain(s)).toList();
    await b.put('playlist_songs_$playlistId', hiveSongs);
  }

  @override
  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    final b = await box;
    final dynamic data = b.get('playlist_songs_$playlistId');
    if (data != null && data is List) {
      return data.cast<HiveSong>().map((e) => e.toDomain()).toList();
    }
    return [];
  }
}
