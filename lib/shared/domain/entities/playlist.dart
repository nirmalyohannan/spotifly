class Playlist {
  final String id;
  final String title;
  final String creator;
  final String coverUrl;
  final String snapshotId;
  final PlaylistOwner? owner;

  Playlist({
    required this.id,
    required this.title,
    required this.creator,
    required this.coverUrl,
    required this.snapshotId,
    required this.owner,
  });
}

class PlaylistOwner {
  final String id;
  final String displayName;
  final String? email;
  final List<String> images;

  PlaylistOwner({
    required this.id,
    required this.displayName,
    required this.email,
    required this.images,
  });
}
