import 'package:spotifly/shared/data/models/spotify_models.dart';
import 'package:spotifly/shared/domain/entities/playlist.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class SpotifyMapper {
  static Song toSong(SpotifyTrack track) {
    return Song(
      id: track.id,
      title: track.name,
      artist: track.artists.map((a) => a.name).join(', '),
      album: track.album.name,
      coverUrl: track.album.images.isNotEmpty
          ? track.album.images.first.url
          : 'https://via.placeholder.com/300',
      duration: Duration(milliseconds: track.durationMs),
      assetUrl: track.previewUrl ?? '',
    );
  }

  static Playlist toPlaylist(SpotifyPlaylist playlist) {
    return Playlist(
      id: playlist.id,
      title: playlist.name,
      creator: playlist.owner.displayName,
      coverUrl: playlist.images.isNotEmpty
          ? playlist.images.first.url
          : 'https://via.placeholder.com/300',
      snapshotId: playlist.snapshotId,
      owner: PlaylistOwner(
        id: playlist.owner.id,
        displayName: playlist.owner.displayName,
        email: playlist.owner.email,
        images: playlist.owner.images.map((i) => i.url).toList(),
      ),
    );
  }
}
