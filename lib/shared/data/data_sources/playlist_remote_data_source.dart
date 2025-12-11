import 'package:spotifly/core/network/spotify_api_client.dart';
import 'package:spotifly/shared/data/models/paginated_spotify_tracks.dart';
import 'package:spotifly/shared/data/models/spotify_models.dart';

abstract class PlaylistRemoteDataSource {
  Future<int> getLikedSongsTotal();
  Future<PaginatedSpotifyTracks> getLikedSongs({
    int offset = 0,
    int limit = 50,
  });
  Future<bool> checkContainsTrack(String trackId);
  Future<void> addTrackToLiked(String trackId);
  Future<void> removeTrackFromLiked(String trackId);
  Future<SpotifyPlaylist> getPlaylist(String playlistId);
  Future<PaginatedSpotifyTracks> getPlaylistTracks(
    String playlistId, {
    int offset = 0,
    int limit = 50,
  });
  Future<List<SpotifyPlaylist>> getUserPlaylists({
    int offset = 0,
    int limit = 50,
  });
  Future<SpotifyUser> getCurrentUserProfile();
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  final SpotifyApiClient _apiClient;

  PlaylistRemoteDataSourceImpl(this._apiClient);

  @override
  Future<int> getLikedSongsTotal() async {
    // Fetching just one item to get the total count efficiently if needed,
    // but the logic in repo was fetching 50. Let's stick to what was there or minimal.
    // Repo was doing: getJson('/me/tracks?offset=0&limit=50') then reading ['total'].
    final data = await _apiClient.getJson('/me/tracks?offset=0&limit=1');
    return data['total'] as int;
  }

  @override
  Future<PaginatedSpotifyTracks> getLikedSongs({
    int offset = 0,
    int limit = 50,
  }) async {
    final data = await _apiClient.getJson(
      '/me/tracks?offset=$offset&limit=$limit',
    );
    final items = data['items'] as List;
    final total = data['total'] as int;

    final tracks = items.map((item) {
      return SpotifyTrack.fromJson(item['track']);
    }).toList();

    return PaginatedSpotifyTracks(items: tracks, total: total);
  }

  @override
  Future<bool> checkContainsTrack(String trackId) async {
    final response = await _apiClient.getJson(
      '/me/tracks/contains?ids=$trackId',
    );
    if (response is List && response.isNotEmpty) {
      return response.first as bool;
    }
    return false;
  }

  @override
  Future<void> addTrackToLiked(String trackId) async {
    var response = await _apiClient.put(
      '/me/tracks',
      body: {
        "ids": [trackId],
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add song to liked');
    }
  }

  @override
  Future<void> removeTrackFromLiked(String trackId) async {
    var response = await _apiClient.delete(
      '/me/tracks',
      body: {
        "ids": [trackId],
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove song from liked');
    }
  }

  @override
  Future<SpotifyPlaylist> getPlaylist(String playlistId) async {
    final data = await _apiClient.getJson('/playlists/$playlistId');
    return SpotifyPlaylist.fromJson(data);
  }

  @override
  Future<PaginatedSpotifyTracks> getPlaylistTracks(
    String playlistId, {
    int offset = 0,
    int limit = 50,
  }) async {
    final tracksData = await _apiClient.getJson(
      '/playlists/$playlistId/tracks?offset=$offset&limit=$limit',
    );
    final tracksItems = (tracksData['items'] as List?) ?? [];
    final total = (tracksData['total'] as int?) ?? 0;

    final tracks = tracksItems
        .map((item) {
          if (item['track'] == null) return null;
          try {
            return SpotifyTrack.fromJson(
              (item['track'] as Map).cast<String, dynamic>(),
            );
          } catch (e) {
            return null;
          }
        })
        .whereType<SpotifyTrack>()
        .toList();

    return PaginatedSpotifyTracks(items: tracks, total: total);
  }

  @override
  Future<List<SpotifyPlaylist>> getUserPlaylists({
    int offset = 0,
    int limit = 50,
  }) async {
    final data = await _apiClient.getJson(
      '/me/playlists?offset=$offset&limit=$limit',
    );
    final items = (data['items'] as List?) ?? [];
    // log('Raw playlists count: ${items.length}');
    return items
        .where((item) => item != null)
        .map((item) {
          try {
            return SpotifyPlaylist.fromJson(
              Map<String, dynamic>.from(item as Map),
            );
          } catch (e) {
            print('Error parsing playlist: $e');
            print('Failed item: $item');
            return null;
          }
        })
        .whereType<SpotifyPlaylist>()
        .toList();
  }

  @override
  Future<SpotifyUser> getCurrentUserProfile() async {
    final data = await _apiClient.getJson('/me');
    return SpotifyUser.fromJson(data);
  }
}
