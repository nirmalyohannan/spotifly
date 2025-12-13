import 'package:hive_ce/hive.dart';
import 'package:spotifly/shared/domain/entities/song.dart';
import '../../domain/entities/cache_source.dart';

part 'cached_song_metadata.g.dart';

@HiveType(typeId: 3)
class CachedSongMetadata extends HiveObject {
  // --- Song Properties ---
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
  final String remoteUrl; // Original URL before caching

  // --- Cache Specific Properties ---
  @HiveField(7)
  final CacheSource source;

  @HiveField(8)
  final String filePath;

  @HiveField(9)
  final DateTime lastPlayedAt;

  @HiveField(10)
  final int fileSize;

  CachedSongMetadata({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.coverUrl,
    required this.durationMs,
    required this.remoteUrl,
    required this.source,
    required this.filePath,
    required this.lastPlayedAt,
    required this.fileSize,
  });

  Song toDomain() {
    return Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      coverUrl: coverUrl,
      duration: Duration(milliseconds: durationMs),
      assetUrl: filePath, // Serve local file path
    );
  }

  factory CachedSongMetadata.fromDomain({
    required Song song,
    required CacheSource source,
    required String filePath,
    required int fileSize,
  }) {
    return CachedSongMetadata(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      coverUrl: song.coverUrl,
      durationMs: song.duration.inMilliseconds,
      remoteUrl: song.assetUrl,
      source: source,
      filePath: filePath,
      lastPlayedAt: DateTime.now(),
      fileSize: fileSize,
    );
  }
}
