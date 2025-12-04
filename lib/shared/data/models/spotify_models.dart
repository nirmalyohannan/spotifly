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
      id: json['id'],
      displayName: json['display_name'],
      email: json['email'],
      images:
          (json['images'] as List?)
              ?.map((e) => SpotifyImage.fromJson(e))
              .toList() ??
          [],
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
      url: json['url'],
      height: json['height'],
      width: json['width'],
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

  SpotifyPlaylist({
    required this.id,
    required this.name,
    this.description,
    required this.images,
    required this.owner,
    this.uri,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    return SpotifyPlaylist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      images:
          (json['images'] as List?)
              ?.map((e) => SpotifyImage.fromJson(e))
              .toList() ??
          [],
      owner: SpotifyUser.fromJson(json['owner']),
      uri: json['uri'],
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
      id: json['id'],
      name: json['name'],
      artists: (json['artists'] as List)
          .map((e) => SpotifyArtist.fromJson(e))
          .toList(),
      album: SpotifyAlbum.fromJson(json['album']),
      durationMs: json['duration_ms'],
      previewUrl: json['preview_url'],
      uri: json['uri'],
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
      id: json['id'],
      name: json['name'],
      images: (json['images'] as List?)
          ?.map((e) => SpotifyImage.fromJson(e))
          .toList(),
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
      id: json['id'],
      name: json['name'],
      images:
          (json['images'] as List?)
              ?.map((e) => SpotifyImage.fromJson(e))
              .toList() ??
          [],
      releaseDate: json['release_date'],
    );
  }
}
