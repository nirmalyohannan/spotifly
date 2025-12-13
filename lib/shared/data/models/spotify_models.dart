class SpotifyUser {
  final String id;
  final String displayName;
  final String? email;
  final List<SpotifyImage> images;

  SpotifyUser({
    required this.id,
    required this.displayName,
    this.email,
    required this.images,
  });

  factory SpotifyUser.fromJson(Map<String, dynamic> json) {
    return SpotifyUser(
      id: json['id']?.toString() ?? 'unknown',
      displayName: json['display_name']?.toString() ?? 'Unknown User',
      email: json['email']?.toString(),
      images: json['images'] is List
          ? (json['images'] as List)
                .whereType<Map>()
                .map((e) => SpotifyImage.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : [],
    );
  }
}

class SpotifyImage {
  final String url;
  final int? height;
  final int? width;

  SpotifyImage({required this.url, this.height, this.width});

  factory SpotifyImage.fromJson(Map<String, dynamic> json) {
    return SpotifyImage(
      url: json['url']?.toString() ?? '',
      height: json['height'] is int
          ? json['height']
          : int.tryParse(json['height']?.toString() ?? ''),
      width: json['width'] is int
          ? json['width']
          : int.tryParse(json['width']?.toString() ?? ''),
    );
  }
}

class SpotifyPlaylist {
  final String id;
  final String name;
  final String? description;
  final List<SpotifyImage> images;
  final SpotifyUser owner;
  final String? uri;
  final String snapshotId;

  SpotifyPlaylist({
    required this.id,
    required this.name,
    this.description,
    required this.images,
    required this.owner,
    this.uri,
    required this.snapshotId,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    return SpotifyPlaylist(
      id: json['id']?.toString() ?? 'unknown',
      name: json['name']?.toString() ?? 'Unknown Playlist',
      description: json['description']?.toString(),
      images: json['images'] is List
          ? (json['images'] as List)
                .whereType<Map>()
                .map((e) => SpotifyImage.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : [],
      owner: json['owner'] is Map
          ? SpotifyUser.fromJson(
              Map<String, dynamic>.from(json['owner'] as Map),
            )
          : SpotifyUser(id: 'unknown', displayName: 'Unknown', images: []),
      uri: json['uri']?.toString(),
      snapshotId: json['snapshot_id']?.toString() ?? '',
    );
  }
}

class SpotifyTrack {
  final String id;
  final String name;
  final List<SpotifyArtist> artists;
  final SpotifyAlbum album;
  final int durationMs;
  final String? previewUrl;
  final String? uri;

  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artists,
    required this.album,
    required this.durationMs,
    this.previewUrl,
    this.uri,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      id: json['id']?.toString() ?? 'unknown',
      name: json['name']?.toString() ?? 'Unknown Track',
      artists: json['artists'] is List
          ? (json['artists'] as List)
                .whereType<Map>()
                .map(
                  (e) => SpotifyArtist.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : [],
      album: json['album'] is Map
          ? SpotifyAlbum.fromJson(
              Map<String, dynamic>.from(json['album'] as Map),
            )
          : SpotifyAlbum(id: 'unknown', name: 'Unknown Album', images: []),
      durationMs: json['duration_ms'] is int
          ? json['duration_ms']
          : int.tryParse(json['duration_ms']?.toString() ?? '') ?? 0,
      previewUrl: json['preview_url']?.toString(),
      uri: json['uri']?.toString(),
    );
  }
}

class SpotifyArtist {
  final String id;
  final String name;
  final List<SpotifyImage>? images;

  SpotifyArtist({required this.id, required this.name, this.images});

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) {
    return SpotifyArtist(
      id: json['id']?.toString() ?? 'unknown',
      name: json['name']?.toString() ?? 'Unknown Artist',
      images: json['images'] is List
          ? (json['images'] as List)
                .whereType<Map>()
                .map((e) => SpotifyImage.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : null,
    );
  }
}

class SpotifyAlbum {
  final String id;
  final String name;
  final List<SpotifyImage> images;
  final String? releaseDate;

  SpotifyAlbum({
    required this.id,
    required this.name,
    required this.images,
    this.releaseDate,
  });

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) {
    return SpotifyAlbum(
      id: json['id']?.toString() ?? 'unknown',
      name: json['name']?.toString() ?? 'Unknown Album',
      images: json['images'] is List
          ? (json['images'] as List)
                .whereType<Map>()
                .map((e) => SpotifyImage.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : [],
      releaseDate: json['release_date']?.toString(),
    );
  }
}
