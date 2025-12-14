import 'package:spotifly/core/di/service_locator.dart';
import 'package:spotifly/core/network/spotify_api_client.dart';
import 'package:spotifly/core/utils/logger.dart';
import 'package:spotifly/features/search/domain/entities/search_results.dart';
import 'package:spotifly/features/search/domain/repositories/search_repository.dart';
import 'package:spotifly/shared/data/models/spotify_models.dart';
import 'package:spotifly/shared/domain/entities/playlist.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SpotifyApiClient _apiClient = getIt<SpotifyApiClient>();

  @override
  Future<SearchResults> search(String query) async {
    if (query.isEmpty) {
      return SearchResults(songs: [], playlists: []);
    }

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final data = await _apiClient.getJson(
        '/search?q=$encodedQuery&type=track,playlist&limit=10',
      );

      final tracksData = (data['tracks']['items'] as List)
          .where((item) => item != null)
          .toList();
      final playlistsData = (data['playlists']['items'] as List)
          .where((item) => item != null)
          .toList();

      final songs = tracksData.map((item) {
        final track = SpotifyTrack.fromJson(item);
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

      final playlists = playlistsData.map((item) {
        final playlist = SpotifyPlaylist.fromJson(item);
        return Playlist(
          id: playlist.id,
          title: playlist.name,
          creator: playlist.owner.displayName,
          coverUrl: playlist.images.isNotEmpty
              ? playlist.images.first.url
              : 'https://via.placeholder.com/300',
          snapshotId: playlist.snapshotId,
        );
      }).toList();

      return SearchResults(songs: songs, playlists: playlists);
    } catch (e) {
      Logger.e('SearchRepositoryImpl: Error searching: $e');
      return SearchResults(songs: [], playlists: []);
    }
  }
}
