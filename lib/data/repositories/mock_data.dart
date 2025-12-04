import '../../domain/entities/song.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/artist.dart';

class MockData {
  static final List<Song> songs = [
    Song(
      id: '1',
      title: 'Easy',
      artist: 'Troye Sivan',
      album: 'Easy',
      coverUrl: 'https://i.scdn.co/image/ab67616d0000b2735d199c0115b2218e9b7327bb', // Example placeholder
      duration: const Duration(minutes: 3, seconds: 46),
      assetUrl: '',
    ),
    Song(
      id: '2',
      title: 'Love Me Do - Mono / Remastered',
      artist: 'The Beatles',
      album: '1 (Remastered)',
      coverUrl: 'https://i.scdn.co/image/ab67616d0000b273e64798f82300126f399a7531',
      duration: const Duration(minutes: 2, seconds: 22),
      assetUrl: '',
    ),
    Song(
      id: '3',
      title: 'From Me to You - Mono / Remastered',
      artist: 'The Beatles',
      album: '1 (Remastered)',
      coverUrl: 'https://i.scdn.co/image/ab67616d0000b273e64798f82300126f399a7531',
      duration: const Duration(minutes: 1, seconds: 57),
      assetUrl: '',
    ),
    Song(
      id: '4',
      title: 'She Loves You - Mono / Remastered',
      artist: 'The Beatles',
      album: '1 (Remastered)',
      coverUrl: 'https://i.scdn.co/image/ab67616d0000b273e64798f82300126f399a7531',
      duration: const Duration(minutes: 2, seconds: 21),
      assetUrl: '',
    ),
    Song(
      id: '5',
      title: 'Venice Bitch',
      artist: 'Lana Del Rey',
      album: 'NFR!',
      coverUrl: 'https://i.scdn.co/image/ab67616d0000b273879e9318cb9f4e05ee552ac9',
      duration: const Duration(minutes: 9, seconds: 37),
      assetUrl: '',
    ),
  ];

  static final List<Album> albums = [
    Album(
      id: '1',
      title: '1 (Remastered)',
      artist: 'The Beatles',
      coverUrl: 'https://i.scdn.co/image/ab67616d0000b273e64798f82300126f399a7531',
      songs: songs.where((s) => s.artist == 'The Beatles').toList(),
    ),
  ];

  static final List<Playlist> playlists = [
    Playlist(
      id: '1',
      title: 'Your Top Songs 2021',
      creator: 'Spotify',
      coverUrl: 'https://misc.scdn.co/liked-songs/liked-songs-300.png', // Placeholder
      songs: songs,
    ),
    Playlist(
      id: '2',
      title: 'Indie Pop',
      creator: 'Spotify',
      coverUrl: 'https://i.scdn.co/image/ab67616d0000b2739613a049320413c9d804599d', // Placeholder
      songs: [songs[0], songs[4]],
    ),
    Playlist(
      id: '3',
      title: 'This Is The Beatles',
      creator: 'Spotify',
      coverUrl: 'https://thisis-images.scdn.co/37i9dQZF1DZ06evO1i2aC7-large.jpg',
      songs: songs.where((s) => s.artist == 'The Beatles').toList(),
    ),
  ];

  static final List<Artist> artists = [
    Artist(
      id: '1',
      name: 'The Beatles',
      imageUrl: 'https://i.scdn.co/image/ab6761610000e5eb43a61c5b54625924779f2e06',
    ),
    Artist(
      id: '2',
      name: 'Lana Del Rey',
      imageUrl: 'https://i.scdn.co/image/ab6761610000e5ebb99cacf8acd5378206767261',
    ),
    Artist(
      id: '3',
      name: 'Troye Sivan',
      imageUrl: 'https://i.scdn.co/image/ab6761610000e5eb44873a5d3f0f7e6e326980a2',
    ),
  ];
  
  static final List<Playlist> recentlyPlayed = [
      playlists[0],
      playlists[1],
      playlists[2],
  ];
  
  static final List<Playlist> yourShows = [
      Playlist(id: 'p1', title: 'The Daily', creator: 'The New York Times', coverUrl: 'https://i.scdn.co/image/ab6765630000ba8a045535125e36ca547b67131c', songs: []),
      Playlist(id: 'p2', title: 'TED Talks Daily', creator: 'TED', coverUrl: 'https://i.scdn.co/image/ab6765630000ba8a150250517c519e3919342105', songs: []),
  ];
}
