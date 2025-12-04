import 'package:spotifly/shared/domain/entities/playlist.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class SearchResults {
  final List<Song> songs;
  final List<Playlist> playlists;
  // Add Artists and Albums later if needed, for now focusing on Songs and Playlists as per existing entities

  SearchResults({required this.songs, required this.playlists});
}
