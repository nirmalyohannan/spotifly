import 'song.dart';

class Playlist {
  final String id;
  final String title;
  final String creator;
  final String coverUrl;
  final List<Song> songs;

  Playlist({
    required this.id,
    required this.title,
    required this.creator,
    required this.coverUrl,
    required this.songs,
  });
}
