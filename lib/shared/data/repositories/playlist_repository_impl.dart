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

  @override
  Future<List<Song>> getLikedSongs() async {
    try {
      final data = await _apiClient.getJson('/me/tracks?limit=50');
      final items = data['items'] as List;
      return items.map((item) {
        final track = SpotifyTrack.fromJson(item['track']);
        return _mapSpotifyTrackToSong(track);
      }).toList();
    } catch (e) {
      log('Error fetching liked songs: $e');
      return [];
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
