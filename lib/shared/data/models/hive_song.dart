import 'package:hive_ce/hive.dart';
import '../../domain/entities/song.dart';

part 'hive_song.g.dart';

@HiveType(typeId: 0)
class HiveSong extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String album;

  @HiveField(4)
  final String coverUrl;

  @HiveField(5)
  final int durationMs;

  @HiveField(6)
  final String assetUrl;

  HiveSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.coverUrl,
    required this.durationMs,
    required this.assetUrl,
  });

  factory HiveSong.fromDomain(Song song) {
    return HiveSong(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      coverUrl: song.coverUrl,
      durationMs: song.duration.inMilliseconds,
      assetUrl: song.assetUrl,
    );
  }

  Song toDomain() {
    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      coverUrl: coverUrl,
      duration: Duration(milliseconds: durationMs),
      assetUrl: assetUrl,
    );
  }
}
