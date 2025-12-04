import 'song.dart';

class Album {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final List<Song> songs;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.songs,
  });
}
