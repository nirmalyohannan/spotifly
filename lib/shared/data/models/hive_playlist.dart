import 'package:hive_ce/hive.dart';
import '../../domain/entities/playlist.dart';

part 'hive_playlist.g.dart';

@HiveType(typeId: 1)
class HivePlaylist extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String creator;

  @HiveField(3)
  final String coverUrl;

  @HiveField(4)
  final String snapshotId;

  HivePlaylist({
    required this.id,
    required this.title,
    required this.creator,
    required this.coverUrl,
    required this.snapshotId,
  });

  factory HivePlaylist.fromDomain(Playlist playlist) {
    return HivePlaylist(
      id: playlist.id,
      title: playlist.title,
      creator: playlist.creator,
      coverUrl: playlist.coverUrl,
      snapshotId: playlist.snapshotId,
    );
  }

  Playlist toDomain() {
    return Playlist(
      id: id,
      title: title,
      creator: creator,
      coverUrl: coverUrl,
      snapshotId: snapshotId,
    );
  }
}
