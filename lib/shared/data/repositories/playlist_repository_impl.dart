import 'dart:async';
import 'dart:developer';

import 'package:spotifly/core/di/service_locator.dart';
import 'package:spotifly/core/network/spotify_api_client.dart';
import 'package:spotifly/shared/data/models/spotify_models.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final SpotifyApiClient _apiClient = getIt<SpotifyApiClient>();

  // Cache
  String? _cachedUserProfileImage;
  List<Playlist>? _cachedPlaylists;

  // Liked Songs Cache
  final List<Song> _cachedLikedSongs = [];
  int? _cachedTotalLikedSongsCount;
  bool _needsRefresh = false;
  bool _isLikedSongsRefreshing = false;

  final _likedSongsController = StreamController<List<Song>>.broadcast();

  @override
  Stream<List<Song>> get likedSongsStream => _likedSongsController.stream;

  @override
  void clearCache() {
    _cachedUserProfileImage = null;
    _cachedPlaylists = null;
    _cachedLikedSongs.clear();
    _cachedTotalLikedSongsCount = null;
    _needsRefresh = false;
    _isLikedSongsRefreshing = false;
  }

  @override
  Future<int> getLikedSongsCount() async {
    try {
      // Fetch the first 50 songs to check consistency and count
      final data = await _apiClient.getJson('/me/tracks?offset=0&limit=50');
      final total = data['total'] as int;
      final items = data['items'] as List;
      final newSongs = items.map((item) {
        final track = SpotifyTrack.fromJson(item['track']);
        return _mapSpotifyTrackToSong(track);
      }).toList();

      // 1. Check if total count matches
      if (_cachedTotalLikedSongsCount != total) {
        _needsRefresh = true;
      }

      // 2. Check if first 50 songs match (only if count matched, otherwise we already know we need refresh)
      if (!_needsRefresh && _cachedLikedSongs.isNotEmpty) {
        int checkLimit = newSongs.length < _cachedLikedSongs.length
            ? newSongs.length
            : _cachedLikedSongs.length;
        if (checkLimit > 50) checkLimit = 50; // Just in case

        for (int i = 0; i < checkLimit; i++) {
          if (newSongs[i].id != _cachedLikedSongs[i].id) {
            _needsRefresh = true;
            break;
          }
        }
      }

      // Update local cache count
      _cachedTotalLikedSongsCount = total;

      // Update the first 50 songs in cache immediately
      for (int i = 0; i < newSongs.length; i++) {
        if (i < _cachedLikedSongs.length) {
          _cachedLikedSongs[i] = newSongs[i];
        } else {
          _cachedLikedSongs.add(newSongs[i]);
        }
      }

      // If we have more items in cache than total, truncate immediately (rare case if deletions didn't sync)
      if (_cachedLikedSongs.length > total) {
        _cachedLikedSongs.removeRange(total, _cachedLikedSongs.length);
      }

      // Emit updated list
      _likedSongsController.add(List.from(_cachedLikedSongs));

      // Trigger background refresh if needed
      if (_needsRefresh && !_isLikedSongsRefreshing) {
        _likedSongsBackgroundRefresh(total);
      }

      return total;
    } catch (e) {
      log('Error fetching liked songs count: $e');
      return _cachedTotalLikedSongsCount ?? 0;
    }
  }

  void _likedSongsBackgroundRefresh(int total) async {
    _isLikedSongsRefreshing = true;
    int offset = 50;
    // If we have fewer than 50 songs, we are done after the initial fetch.

    while (offset < total) {
      // 2 seconds gap
      await Future.delayed(const Duration(seconds: 2));

      try {
        final data = await _apiClient.getJson(
          '/me/tracks?offset=$offset&limit=50',
        );
        final items = data['items'] as List;
        final pageSongs = items.map((item) {
          final track = SpotifyTrack.fromJson(item['track']);
          return _mapSpotifyTrackToSong(track);
        }).toList();

        // Update cache ensuring index alignment
        for (int i = 0; i < pageSongs.length; i++) {
          int targetIndex = offset + i;
          if (targetIndex < _cachedLikedSongs.length) {
            _cachedLikedSongs[targetIndex] = pageSongs[i];
          } else {
            _cachedLikedSongs.add(pageSongs[i]);
          }
        }

        // Emit update after each page
        _likedSongsController.add(List.from(_cachedLikedSongs));

        offset += 50;

        // Re-check total from API response?
        // The API returns total in every page. We could adapt if it changes mid-stream.
        if (data['total'] != null) {
          int newTotal = data['total'];
          if (newTotal != total) {
            total = newTotal;
            _cachedTotalLikedSongsCount = total;
          }
        }
      } catch (e) {
        log('Error refreshing liked songs background at offset $offset: $e');
        // Break or retry? Break to avoid infinite loops or spamming errors.
        break;
      } finally {
        _isLikedSongsRefreshing = false;
      }
    }

    // Final cleanup: if cache exceeded total (e.g. tracks deleted while syncing)
    if (_cachedLikedSongs.length > total) {
      _cachedLikedSongs.removeRange(total, _cachedLikedSongs.length);
      _likedSongsController.add(List.from(_cachedLikedSongs));
    }
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    try {
      final data = await _apiClient.getJson('/playlists/$id');
      final spotifyPlaylist = SpotifyPlaylist.fromJson(data);

      // Fetch tracks for this playlist
      final tracksData = await _apiClient.getJson('/playlists/$id/tracks');
      final tracksItems = tracksData['items'] as List;
      final songs = tracksItems
          .map((item) {
            if (item['track'] == null) return null;
            final track = SpotifyTrack.fromJson(item['track']);
            return _mapSpotifyTrackToSong(track);
          })
          .whereType<Song>()
          .toList();

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
      final data = await _apiClient.getJson('/me/playlists');
      final items = data['items'] as List;
      _cachedPlaylists = items.map((item) {
        final spotifyPlaylist = SpotifyPlaylist.fromJson(item);
        return Playlist(
          id: spotifyPlaylist.id,
          title: spotifyPlaylist.name,
          creator: spotifyPlaylist.owner.displayName,
          coverUrl: spotifyPlaylist.images.isNotEmpty
              ? spotifyPlaylist.images.first.url
              : 'https://via.placeholder.com/300',
          songs: [], // Tracks are not returned in the list endpoint
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
      final data = await _apiClient.getJson('/me');
      final images = data['images'] as List;
      if (images.isNotEmpty) {
        _cachedUserProfileImage = images.first['url'] as String;
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
      var response = await _apiClient.put(
        '/me/tracks',
        body: {
          "ids": [song.id],
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to add song to liked');
      }

      // Update Cache
      _cachedLikedSongs.insert(0, song);
      _cachedTotalLikedSongsCount = _cachedTotalLikedSongsCount! + 1;
    } catch (e) {
      log('Error adding song to liked: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeSongFromLiked(String songId) async {
    try {
      var response = await _apiClient.delete(
        '/me/tracks',
        body: {
          "ids": [songId],
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to remove song from liked');
      }

      // Update Cache
      _cachedLikedSongs.removeWhere((song) => song.id == songId);
      if (_cachedTotalLikedSongsCount != null &&
          _cachedTotalLikedSongsCount! > 0) {
        _cachedTotalLikedSongsCount = _cachedTotalLikedSongsCount! - 1;
      }
    } catch (e) {
      log('Error removing song from liked: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isSongLiked(String songId) async {
    //Check if it is in cache if cache is uptodate
    if (_needsRefresh == false) {
      if (_cachedLikedSongs.any((s) => s.id == songId)) {
        return true;
      }
    }

    try {
      final response = await _apiClient.getJson(
        '/me/tracks/contains?ids=$songId',
      );
      if (response is List && response.isNotEmpty) {
        return response.first as bool;
      }
      return false;
    } catch (e) {
      log('Error checking if song is liked: $e');
      return false;
    }
  }

  Song _mapSpotifyTrackToSong(SpotifyTrack track) {
    return Song(
      id: track.id,
      title: track.name,
      artist: track.artists.map((a) => a.name).join(', '),
      album: track.album.name,
      coverUrl: track.album.images.isNotEmpty
          ? track.album.images.first.url
          : 'https://via.placeholder.com/300',
      duration: Duration(milliseconds: track.durationMs),
      assetUrl: track.previewUrl ?? '',
    );
  }
}
