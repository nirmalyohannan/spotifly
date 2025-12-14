import 'dart:async';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:spotifly/shared/data/data_sources/playlist_local_data_source.dart';
import 'package:spotifly/shared/data/data_sources/playlist_remote_data_source.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../mappers/spotify_mapper.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistRemoteDataSource _remoteDataSource;
  final PlaylistLocalDataSource _localDataSource;

  PlaylistRepositoryImpl(this._remoteDataSource, this._localDataSource);

  // Cache - User Profile & Playlists can remain in memory or move to Hive later if requested.
  // For now task only mentioned LikedSongs variables.
  String? _cachedUserProfileImage;
  List<Playlist>? _cachedPlaylists;

  bool _isLikedSongsRefreshing = false;

  final _likedSongsController = StreamController<List<Song>>.broadcast();

  // Deprecated in-memory variables removed:
  // _cachedLikedSongs, _cachedTotalLikedSongsCount, _needsRefresh

  @override
  Stream<List<Song>> get likedSongsStream => _likedSongsController.stream;

  @override
  Future<List<Song>> getLikedSongs() async {
    try {
      // Try local first
      final localSongs = await _localDataSource.getLikedSongs();
      if (localSongs.isNotEmpty) {
        return localSongs;
      }

      // If empty, trigger a refresh (this will fetch from remote and update cache)
      await getLikedSongsCount();

      // Return updated local
      return await _localDataSource.getLikedSongs();
    } catch (e) {
      log('Error getting liked songs: $e');
      return [];
    }
  }

  @override
  Future<void> clearCache() async {
    _cachedUserProfileImage = null;
    _cachedPlaylists = null;

    // Clear Hive data
    await _localDataSource.clear();

    _isLikedSongsRefreshing = false;
    _syncPlaylistController?.close();
    _syncPlaylistController = null;
  }

  @override
  Future<int> getLikedSongsCount() async {
    try {
      // 1. Get local data first to allow immediate UI display from cache
      final localCount = await _localDataSource.getLikedSongsCount();
      final localSongs = await _localDataSource.getLikedSongs();

      // Emit what we have immediately
      if (localSongs.isNotEmpty) {
        _likedSongsController.add(localSongs);
      }

      // 2. Fetch the first 50 songs from API
      // Use Remote Data Source
      final remoteData = await _remoteDataSource.getLikedSongs(
        offset: 0,
        limit: 50,
      );
      final apiTotal = remoteData.total;
      final newSongs = remoteData.items.map(SpotifyMapper.toSong).toList();

      bool needsRefresh = false;
      bool localNeedsRefresh = await _localDataSource.getNeedsRefresh();

      // Check consistency
      if (localCount != apiTotal) {
        needsRefresh = true;
      }

      if (!needsRefresh && !localNeedsRefresh && localSongs.isNotEmpty) {
        int checkLimit = newSongs.length < localSongs.length
            ? newSongs.length
            : localSongs.length;
        if (checkLimit > 50) checkLimit = 50;

        for (int i = 0; i < checkLimit; i++) {
          if (newSongs[i].id != localSongs[i].id) {
            needsRefresh = true;
            break;
          }
        }
      }

      // Update local cache count
      await _localDataSource.cacheLikedSongsCount(apiTotal);

      // Update the first 50 songs in cache immediately
      // We need to fetch full list to modify it?
      // Or we can just read current, modify, write.
      // Since localSongs variable has current, let's use it.
      List<Song> updatedSongs = List.from(localSongs);

      for (int i = 0; i < newSongs.length; i++) {
        if (i < updatedSongs.length) {
          updatedSongs[i] = newSongs[i];
        } else {
          updatedSongs.add(newSongs[i]);
        }
      }

      if (updatedSongs.length > apiTotal) {
        updatedSongs.removeRange(apiTotal, updatedSongs.length);
      }

      await _localDataSource.cacheLikedSongs(updatedSongs);

      // Refetch to be safely consistent or just use updatedSongs
      _likedSongsController.add(updatedSongs);

      if (needsRefresh) {
        await _localDataSource.setNeedsRefresh(true);
        _startBackgroundRefresh(apiTotal);
      } else {
        await _localDataSource.setNeedsRefresh(false);
      }

      return apiTotal;
    } catch (e) {
      log('Error fetching liked songs count: $e');
      return await _localDataSource.getLikedSongsCount() ?? 0;
    }
  }

  void _startBackgroundRefresh(int total) {
    if (!_isLikedSongsRefreshing) {
      _likedSongsBackgroundRefresh(total);
    }
  }

  void _likedSongsBackgroundRefresh(int total) async {
    _isLikedSongsRefreshing = true;
    int offset = 50;

    // We maintain a working copy of the list to save incrementally
    List<Song> currentSongs = await _localDataSource.getLikedSongs();

    while (offset < total) {
      await Future.delayed(const Duration(seconds: 1));

      try {
        final remoteData = await _remoteDataSource.getLikedSongs(
          offset: offset,
          limit: 50,
        );

        final pageSongs = remoteData.items.map(SpotifyMapper.toSong).toList();

        // Update local list
        for (int i = 0; i < pageSongs.length; i++) {
          int targetIndex = offset + i;
          if (targetIndex < currentSongs.length) {
            currentSongs[targetIndex] = pageSongs[i];
          } else {
            currentSongs.add(pageSongs[i]);
          }
        }

        await _localDataSource.cacheLikedSongs(currentSongs);
        _likedSongsController.add(List.from(currentSongs));

        offset += 50;

        // Check if total changed during pagination
        if (remoteData.total != total) {
          total = remoteData.total;
          await _localDataSource.cacheLikedSongsCount(total);
        }
      } catch (e) {
        log('Error refreshing liked songs background at offset $offset: $e');
        break;
      }
    }

    // Final check for truncation
    if (currentSongs.length > total) {
      currentSongs.removeRange(total, currentSongs.length);
      await _localDataSource.cacheLikedSongs(currentSongs);
      _likedSongsController.add(currentSongs);
    }

    _isLikedSongsRefreshing = false;
    await _localDataSource.setNeedsRefresh(false);
  }

  @override
  Future<List<Song>> getPlaylistSongs(String id, String? snapshotId) async {
    try {
      log('getPlaylistSongs() ID: $id  snapshotId: $snapshotId');
      // Attempt to retrieve playlist metadata from local cache first.
      final localPlaylists = await _localDataSource.getUserPlaylists();
      final localPlaylist = localPlaylists.cast<Playlist?>().firstWhere(
        (p) => p?.id == id,
        orElse: () => null,
      );

      // If a local playlist is found and its snapshotId matches the provided one,
      // and local songs exist, return the cached version to avoid remote call.
      if (localPlaylist != null &&
          snapshotId != null &&
          snapshotId == localPlaylist.snapshotId) {
        final localSongs = await _localDataSource.getPlaylistSongs(id);
        if (localSongs.isNotEmpty) {
          return localSongs;
        }
      }

      // 2. Fetch all songs from remote, handling pagination for potentially large playlists.
      List<Song> allSongs = [];
      int offset = 0;
      const limit = 50;
      bool hasMore = true;

      while (hasMore) {
        final paginatedTracks = await _remoteDataSource.getPlaylistTracks(
          id,
          offset: offset,
          limit: limit,
        );

        final songs = paginatedTracks.items.map(SpotifyMapper.toSong).toList();
        allSongs.addAll(songs);

        // Determine if more pages need to be fetched.
        if (paginatedTracks.items.length < limit) {
          hasMore = false;
        } else {
          offset += limit;
        }
      }

      // 3. Cache the newly fetched songs locally for future use.
      await _localDataSource.cachePlaylistSongs(id, allSongs);

      // Return the complete list of songs from remote data and all fetched songs.
      return allSongs;
    } catch (e) {
      log('getPlaylistSongs():Playlist ID $id Error: $e');
      // Fallback to local data if remote fetch fails.
      final localSongs = await _localDataSource.getPlaylistSongs(id);
      return localSongs;
    }
  }

  Future<List<Playlist>> _getCachedPlaylists() async {
    if (_cachedPlaylists != null && _cachedPlaylists!.isNotEmpty) {
      return _cachedPlaylists!;
    }
    try {
      final localPlaylists = await _localDataSource.getUserPlaylists();
      if (localPlaylists.isNotEmpty) {
        _cachedPlaylists = localPlaylists;
      }
      return localPlaylists;
    } catch (e) {
      log('_getCachedPlaylists() Error fetching local playlists: $e');
      return [];
    }
  }

  @override
  Future<String?> getUserProfileImage() async {
    if (_cachedUserProfileImage != null) {
      return _cachedUserProfileImage;
    }
    try {
      final user = await _remoteDataSource.getCurrentUserProfile();
      if (user.images.isNotEmpty) {
        _cachedUserProfileImage = user.images.first.url;
        return _cachedUserProfileImage;
      }
      return null;
    } catch (e) {
      log('Error fetching user profile: $e');
      return null;
    }
  }

  @override
  Future<void> addSongToLiked(Song song) async {
    try {
      await _remoteDataSource.addTrackToLiked(song.id);

      await _localDataSource.addSongToLiked(song);
      final count = await _localDataSource.getLikedSongsCount();
      if (count != null) {
        await _localDataSource.cacheLikedSongsCount(count + 1);
      }

      // Update stream
      _likedSongsController.add(await _localDataSource.getLikedSongs());
    } catch (e) {
      log('addSongToLiked() Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeSongFromLiked(String songId) async {
    try {
      await _remoteDataSource.removeTrackFromLiked(songId);

      await _localDataSource.removeSongFromLiked(songId);
      final count = await _localDataSource.getLikedSongsCount();
      if (count != null && count > 0) {
        await _localDataSource.cacheLikedSongsCount(count - 1);
      }

      // Update stream
      _likedSongsController.add(await _localDataSource.getLikedSongs());
    } catch (e) {
      log('removeSongFromLiked() Error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isSongLiked(String songId) async {
    final needsRefresh = await _localDataSource.getNeedsRefresh();
    if (!needsRefresh) {
      final songs = await _localDataSource.getLikedSongs();
      if (songs.any((s) => s.id == songId)) {
        return true;
      }
    }

    try {
      return await _remoteDataSource.checkContainsTrack(songId);
    } catch (e) {
      log('isSongLiked() Error: $e');
      return false;
    }
  }

  BehaviorSubject<List<Playlist>>? _syncPlaylistController;

  @override
  Stream<List<Playlist>> loadPlaylistsWithSync() {
    //If Stream is already open, return it avoiding multiple API Calls
    if (_syncPlaylistController != null && _syncPlaylistController!.isClosed) {
      return _syncPlaylistController!.stream;
    }
    //Create a new stream
    _syncPlaylistController = BehaviorSubject<List<Playlist>>();

    //Start the sync process
    _startPlaylistSync().then((_) {
      //Close the stream on completion
      _syncPlaylistController!.close();
    });

    return _syncPlaylistController!.stream;
  }

  Future<void> _startPlaylistSync() async {
    try {
      log('_startPlaylistSync(): Started');
      //Fetch cached playlists and emit
      var cachedPlaylists = await _getCachedPlaylists();
      _syncPlaylistController!.add(cachedPlaylists);

      //Fetch remote playlists and map to Playlist entity and emit
      var remotePlaylists = (await _fetchAllRemotePlaylists()).toList();
      _syncPlaylistController!.add(remotePlaylists);

      //Compare remote and cached playlists to get outdated playlists
      final outDatedPlaylists = remotePlaylists.where((remotePlaylist) {
        var cachePlaylist = cachedPlaylists
            .where((p) => p.id == remotePlaylist.id)
            .firstOrNull;
        return remotePlaylist.snapshotId != (cachePlaylist?.snapshotId);
      }).toList();

      //Use the outdated playlists to fetch it's songs and cache them
      for (Playlist playlist in outDatedPlaylists) {
        await Future.delayed(const Duration(milliseconds: 600));
        //Compares the snapshotId and fetches from API if needs update
        await getPlaylistSongs(playlist.id, playlist.snapshotId);

        //Update in cache and local database as soon as each playlist is updated
        //As much as cached stays persistent even if the app is closed in between
        _replaceCacheItem(playlist);
      }

      //Update the cache
      _cachedPlaylists = remotePlaylists;
      await _localDataSource.cacheUserPlaylists(remotePlaylists);
      log('_startPlaylistSync(): Completed.');
    } catch (e) {
      log('_startPlaylistSync(): Error: $e');
    }
  }

  /// Fetches all remote playlists paginated through while loop
  Future<List<Playlist>> _fetchAllRemotePlaylists() async {
    List<Playlist> allRemotePlaylists = [];
    int offset = 0;
    const limit = 50;
    bool hasMore = true;
    while (hasMore) {
      await Future.delayed(const Duration(milliseconds: 600));
      final spotifyPlaylists = await _remoteDataSource.getUserPlaylists(
        offset: offset,
        limit: limit,
      );
      final playlists = spotifyPlaylists.map(SpotifyMapper.toPlaylist).toList();
      allRemotePlaylists.addAll(playlists);
      if (spotifyPlaylists.length < limit) {
        hasMore = false;
      } else {
        offset += limit;
      }
    }
    return allRemotePlaylists;
  }

  /// Replaces the cache item with the given playlist item
  /// If the playlist is not in the cache, it is added to the cache
  Future<void> _replaceCacheItem(Playlist playlist) async {
    if (_cachedPlaylists != null) {
      _cachedPlaylists = [];
    }
    for (var i = 0; i < _cachedPlaylists!.length; i++) {
      if (_cachedPlaylists![i].id == playlist.id) {
        _cachedPlaylists![i] = playlist;
        return;
      }
    }
    _cachedPlaylists!.add(playlist);
    await _localDataSource.cacheUserPlaylists(_cachedPlaylists!);
  }
}
