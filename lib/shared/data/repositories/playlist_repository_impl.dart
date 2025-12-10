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

  final _likedSongsController = StreamController<List<Song>>.broadcast();

  // Deprecated in-memory variables removed:
  // _cachedLikedSongs, _cachedTotalLikedSongsCount, _needsRefresh

  @override
  Stream<List<Song>> get likedSongsStream => _likedSongsController.stream;

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
      await Future.delayed(const Duration(seconds: 2));

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
      final spotifyPlaylist = await _remoteDataSource.getPlaylist(id);
      final tracks = await _remoteDataSource.getPlaylistTracks(id);

      final songs = tracks.map(SpotifyMapper.toSong).toList();

      return Playlist(
        id: spotifyPlaylist.id,
        title: spotifyPlaylist.name,
        creator: spotifyPlaylist.owner.displayName,
        coverUrl: spotifyPlaylist.images.isNotEmpty
            ? spotifyPlaylist.images.first.url
            : 'https://via.placeholder.com/300',
        songs: songs,
      );
    } catch (e) {
      log('Error fetching playlist $id: $e');
      return null;
    }
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    if (_cachedPlaylists != null) {
      return _cachedPlaylists!;
    }
    try {
      final spotifyPlaylists = await _remoteDataSource.getUserPlaylists();

      _cachedPlaylists = spotifyPlaylists.map((spotifyPlaylist) {
        return Playlist(
          id: spotifyPlaylist.id,
          title: spotifyPlaylist.name,
          creator: spotifyPlaylist.owner.displayName,
          coverUrl: spotifyPlaylist.images.isNotEmpty
              ? spotifyPlaylist.images.first.url
              : 'https://via.placeholder.com/300',
          songs: [],
        );
      }).toList();
      return _cachedPlaylists!;
    } catch (e) {
      log('Error fetching playlists: $e');
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
}
