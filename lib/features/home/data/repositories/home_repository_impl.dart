import 'dart:developer';

import 'package:spotifly/core/di/service_locator.dart';
import 'package:spotifly/core/network/spotify_api_client.dart';
import 'package:spotifly/features/home/domain/repositories/home_repository.dart';
import 'package:spotifly/shared/data/models/spotify_models.dart';
import 'package:spotifly/shared/domain/entities/playlist.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class HomeRepositoryImpl implements HomeRepository {
  final SpotifyApiClient _apiClient = getIt<SpotifyApiClient>();

  @override
  Future<List<Playlist>> getFeaturedPlaylists() async {
    try {
      final data = await _apiClient.getJson('/browse/featured-playlists');
      final items = data['playlists']['items'] as List;
      return items.map((item) {
        final spotifyPlaylist = SpotifyPlaylist.fromJson(item);
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
    } catch (e) {
      log('Error fetching featured playlists: $e');
      return [];
    }
  }

  @override
  Future<List<Playlist>> getNewReleases() async {
    try {
      final data = await _apiClient.getJson('/browse/new-releases');
      final items = data['albums']['items'] as List;
      return items.map((item) {
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
        );
      }).toList();
    } catch (e) {
      log('Error fetching new releases: $e');
      return [];
    }
  }

  @override
  Future<List<Song>> getRecentlyPlayed() async {
    try {
      final data = await _apiClient.getJson(
        '/me/player/recently-played?limit=20',
      );
      final items = data['items'] as List;
      return items.map((item) {
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
    } catch (e) {
      log('Error fetching recently played: $e');
      return [];
    }
  }
}
