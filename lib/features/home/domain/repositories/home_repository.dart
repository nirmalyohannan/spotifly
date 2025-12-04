import 'package:spotifly/shared/domain/entities/playlist.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

abstract class HomeRepository {
  Future<List<Song>> getRecentlyPlayed();
  Future<List<Playlist>> getFeaturedPlaylists();
  Future<List<Playlist>>
  getNewReleases(); // Mapping albums to playlists for simplicity in UI
}
