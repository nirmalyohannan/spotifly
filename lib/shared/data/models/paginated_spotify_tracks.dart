import 'package:spotifly/shared/data/models/spotify_models.dart';

class PaginatedSpotifyTracks {
  final List<SpotifyTrack> items;
  final int total;

  PaginatedSpotifyTracks({required this.items, required this.total});
}
