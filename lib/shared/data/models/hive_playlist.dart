import 'package:hive_ce/hive.dart';
import '../../domain/entities/playlist.dart';

part 'hive_playlist.g.dart';

@HiveType(typeId: 4)
class HivePlaylistOwner {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String displayName;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final List<String> images;

  HivePlaylistOwner({
    required this.id,
    required this.displayName,
    required this.email,
    required this.images,
  });

  factory HivePlaylistOwner.fromDomain(PlaylistOwner owner) {
    return HivePlaylistOwner(
      id: owner.id,
      displayName: owner.displayName,
      email: owner.email,
      images: owner.images,
    );
  }

  PlaylistOwner toDomain() {
    return PlaylistOwner(
      id: id,
      displayName: displayName,
      email: email,
      images: images,
    );
  }
}

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

  @HiveField(5)
  final HivePlaylistOwner? owner;

  HivePlaylist({
    required this.id,
    required this.title,
    required this.creator,
    required this.coverUrl,
    required this.snapshotId,
    required this.owner,
  });

  factory HivePlaylist.fromDomain(Playlist playlist) {
    return HivePlaylist(
      id: playlist.id,
      title: playlist.title,
      creator: playlist.creator,
      coverUrl: playlist.coverUrl,
      snapshotId: playlist.snapshotId,
      owner: playlist.owner != null
          ? HivePlaylistOwner.fromDomain(playlist.owner!)
          : null,
    );
  }

  Playlist toDomain() {
    return Playlist(
      id: id,
      title: title,
      creator: creator,
      coverUrl: coverUrl,
      snapshotId: snapshotId,
      owner: owner?.toDomain(),
    );
  }
}
