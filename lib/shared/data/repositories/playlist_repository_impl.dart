import 'dart:async';
import 'dart:developer';

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
  bool _isLibrarySyncing = false;

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
  void clearCache() {
    _cachedUserProfileImage = null;
    _cachedPlaylists = null;
    // We might want to clear local storage too on logout?
    // User requested "logout user use case should clear... reset in-memory caches".
    // If we use Hive, we should probably clear it on logout.
    // However, existing clearCache was for memory.
    // Let's clear local data source for privacy on logout if this method is used for logout.
    // But since this method is sync in interface, we can't await.
    // We should probably rely on the logout use case handling local data source clearing or ignore for now.
    // Or just clear memory state variables.
    // For now, let's keep it simple.
    _isLikedSongsRefreshing = false;
    _isLibrarySyncing = false;
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
  Future<Playlist?> getPlaylistById(String id) async {
    try {
      log('Fetching playlist by ID: $id');
      final spotifyPlaylist = await _remoteDataSource.getPlaylist(id);
      final remoteSnapshotId = spotifyPlaylist.snapshotId;

      // 1. Try to get local playlist songs logic if needed,
      // but here we are fetching full playlist details.
      // We can check if we have this playlist locally in user playlists to compare snapshotId,
      // OR we can just check if we have songs for this playlist cached and if they match snapshot?
      // But we don't store snapshotId with songs list directly,
      // though we can fetch local user playlists to find the playlist and check snapshotId.

      final localPlaylists = await _localDataSource.getUserPlaylists();
      final localPlaylist = localPlaylists.cast<Playlist?>().firstWhere(
        (p) => p?.id == id,
        orElse: () => null,
      );

      // If local exists and snapshot matches, return local songs
      if (localPlaylist != null &&
          localPlaylist.snapshotId == remoteSnapshotId) {
        final localSongs = await _localDataSource.getPlaylistSongs(id);
        if (localSongs.isNotEmpty) {
          return Playlist(
            id: spotifyPlaylist.id,
            title: spotifyPlaylist.name,
            creator: spotifyPlaylist.owner.displayName,
            coverUrl: spotifyPlaylist.images.isNotEmpty
                ? spotifyPlaylist.images.first.url
                : 'https://via.placeholder.com/300',
            songs: localSongs,
            snapshotId: remoteSnapshotId,
          );
        }
      }

      // 2. Fetch all songs from remote (Paginated)
      List<Song> allSongs = [];
      int offset = 0;
      const limit = 50;
      // First call to get total? Or just loop.
      // Remote source `getPlaylistTracks` returns `PaginatedSpotifyTracks`.
      bool hasMore = true;

      while (hasMore) {
        final paginatedTracks = await _remoteDataSource.getPlaylistTracks(
          id,
          offset: offset,
          limit: limit,
        );

        final songs = paginatedTracks.items.map(SpotifyMapper.toSong).toList();
        allSongs.addAll(songs);

        if (paginatedTracks.items.length < limit) {
          hasMore = false;
        } else {
          offset += limit;
        }
      }

      // 3. Cache songs
      await _localDataSource.cachePlaylistSongs(id, allSongs);

      // Also update the playlist object in user playlists list if needed?
      // Maybe not strictly required if we trust `getUserPlaylists` to update that list periodically.
      // But for consistency we might want to update the snapshotId in our local playlist list if we found it mismatched?
      // However, `remoteDataSource.getPlaylist` gave us the new snapshotId.
      // If we are here, we probably have new songs.

      return Playlist(
        id: spotifyPlaylist.id,
        title: spotifyPlaylist.name,
        creator: spotifyPlaylist.owner.displayName,
        coverUrl: spotifyPlaylist.images.isNotEmpty
            ? spotifyPlaylist.images.first.url
            : 'https://via.placeholder.com/300',
        songs: allSongs,
        snapshotId: remoteSnapshotId,
      );
    } catch (e) {
      log('Error fetching playlist $id: $e');
      // Fallback to local
      final localSongs = await _localDataSource.getPlaylistSongs(id);
      // We might not have the playlist metadata if we fail to fetch it from remote...
      // But we can try to find it in local playlists cache.
      final localPlaylists = await _localDataSource.getUserPlaylists();
      final localPlaylist = localPlaylists.cast<Playlist?>().firstWhere(
        (p) => p?.id == id,
        orElse: () => null,
      );

      if (localPlaylist != null) {
        return Playlist(
          id: localPlaylist.id,
          title: localPlaylist.title,
          creator: localPlaylist.creator,
          coverUrl: localPlaylist.coverUrl,
          songs: localSongs, // might be empty
          snapshotId: localPlaylist.snapshotId,
        );
      }
      return null;
    }
  }

  @override
  Future<List<Playlist>> getCachedPlaylists() async {
    if (_cachedPlaylists != null && _cachedPlaylists!.isNotEmpty) {
      return _cachedPlaylists!;
    }
    try {
      log('Fetching local playlists...');
      final localPlaylists = await _localDataSource.getUserPlaylists();
      log('Local playlists found: ${localPlaylists.length}');
      if (localPlaylists.isNotEmpty) {
        _cachedPlaylists = localPlaylists;
      }
      return localPlaylists;
    } catch (e) {
      log('Error fetching local playlists: $e');
      return [];
    }
  }

  @override
  Future<List<Playlist>> refreshPlaylists() async {
    try {
      log('Fetching remote playlists...');
      // Fetch remote playlists (Paginated)
      List<Playlist> allRemotePlaylists = [];
      int offset = 0;
      const limit = 50;
      bool hasMore = true;

      while (hasMore) {
        await Future.delayed(const Duration(milliseconds: 600));
        log('Fetching remote playlists offset: $offset');
        final spotifyPlaylists = await _remoteDataSource.getUserPlaylists(
          offset: offset,
          limit: limit,
        );
        log('Remote playlists fetched: ${spotifyPlaylists.length}');

        final playlists = spotifyPlaylists.map((spotifyPlaylist) {
          return Playlist(
            id: spotifyPlaylist.id,
            title: spotifyPlaylist.name,
            creator: spotifyPlaylist.owner.displayName,
            coverUrl: spotifyPlaylist.images.isNotEmpty
                ? spotifyPlaylist.images.first.url
                : 'https://via.placeholder.com/300',
            songs: [],
            snapshotId: spotifyPlaylist.snapshotId,
          );
        }).toList();

        allRemotePlaylists.addAll(playlists);

        if (spotifyPlaylists.length < limit) {
          hasMore = false;
        } else {
          offset += limit;
        }
      }

      log('Total remote playlists: ${allRemotePlaylists.length}');

      // Update Cache & Local Storage
      _cachedPlaylists = allRemotePlaylists;
      await _localDataSource.cacheUserPlaylists(allRemotePlaylists);
      log('Cached user playlists to Hive');

      return _cachedPlaylists!;
    } catch (e, stack) {
      log('Error fetching playlists: $e');
      log('Stack trace: $stack');
      // If we differ from original logic which just rethrew if cache empty:
      // We should probably rethrow here so the caller knows refresh failed?
      // Or return cached if available?
      // The original getPlaylists rethrows if cache is empty.
      // Let's stick to that pattern for refreshPlaylists.
      if (_cachedPlaylists == null || _cachedPlaylists!.isEmpty) {
        rethrow;
      }
      return _cachedPlaylists!;
    }
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    // Legacy support: try to get local first (implicit in refresh logic fallback? no).
    // Original logic: Try local, then try remote.
    // We can call getCachedPlaylists just to populate `_cachedPlaylists` in case `refreshPlaylists` fails and needs it for fallback.
    await getCachedPlaylists();
    return refreshPlaylists();
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
      log('Error adding song to liked: $e');
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
      log('Error removing song from liked: $e');
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
      log('Error checking if song is liked: $e');
      return false;
    }
  }

  @override
  Future<void> syncLibrary() async {
    if (_isLibrarySyncing) return;
    _isLibrarySyncing = true;
    // Only start if not already refreshing?
    // We don't have a global _isLibrarySyncing flag, but this is usually called once on startup.
    // Let's fire and forget.
    _syncPlaylistsAndSongs();
  }

  Future<void> _syncPlaylistsAndSongs() async {
    log('Syncing library...');
    try {
      var playlists = await refreshPlaylists();
      for (var playlist in playlists) {
        await Future.delayed(const Duration(milliseconds: 600));
        await getPlaylistById(playlist.id);
      }
      log('Library sync: Completed.');
    } catch (e) {
      log('Error syncing library: $e');
    }
  }
}
