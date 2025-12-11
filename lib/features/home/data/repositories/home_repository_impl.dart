import 'dart:developer';

import 'package:spotifly/core/di/service_locator.dart';
import 'package:spotifly/core/network/spotify_api_client.dart';
import 'package:spotifly/features/home/domain/repositories/home_repository.dart';
import 'package:spotifly/shared/data/models/spotify_models.dart';
import 'package:spotifly/shared/domain/entities/playlist.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class HomeRepositoryImpl implements HomeRepository {
  final SpotifyApiClient _apiClient = getIt<SpotifyApiClient>();

  // Cache
  List<Playlist>? _cachedNewReleases;
  List<Song>? _cachedRecentlyPlayed;

  @override
  void clearCache() {
    _cachedNewReleases = null;
    _cachedRecentlyPlayed = null;
  }

  @override
  Future<List<Playlist>> getNewReleases() async {
    if (_cachedNewReleases != null) {
      return _cachedNewReleases!;
    }
    try {
      final data = await _apiClient.getJson('/browse/new-releases');
      final items = data['albums']['items'] as List;
      _cachedNewReleases = items.map((item) {
        final album = SpotifyAlbum.fromJson(item);
        // Mapping Album to Playlist entity for UI reuse
        return Playlist(
          id: album.id,
          title: album.name,
          creator:
              'New Release', // Or artist name if available in simplified album object
          coverUrl: album.images.isNotEmpty
              ? album.images.first.url
              : 'https://via.placeholder.com/300',
          songs: [],
          snapshotId: '', // Albums don't have snapshot_id like playlists
        );
      }).toList();
      return _cachedNewReleases!;
    } catch (e) {
      log('Error fetching new releases: $e');
      return [];
    }
  }

  @override
  Future<List<Song>> getRecentlyPlayed() async {
    if (_cachedRecentlyPlayed != null) {
      return _cachedRecentlyPlayed!;
    }
    try {
      final data = await _apiClient.getJson(
        '/me/player/recently-played?limit=20',
      );
      final items = data['items'] as List;
      _cachedRecentlyPlayed = items.map((item) {
        final track = SpotifyTrack.fromJson(item['track']);
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
      }).toList();
      return _cachedRecentlyPlayed!;
    } catch (e) {
      log('Error fetching recently played: $e');
      return [];
    }
  }
}
