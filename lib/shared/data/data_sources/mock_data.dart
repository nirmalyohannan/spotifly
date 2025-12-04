import 'package:spotifly/shared/domain/entities/song.dart';
import 'package:spotifly/shared/domain/entities/album.dart';
import 'package:spotifly/shared/domain/entities/playlist.dart';
import 'package:spotifly/shared/domain/entities/artist.dart';

class MockData {
  static final List<Song> songs = [
    Song(
      id: '1',
      title: 'Starboy',
      artist: 'The Weeknd, Daft Punk',
      album: 'Starboy',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/3/39/The_Weeknd_-_Starboy.png',
      duration: const Duration(minutes: 3, seconds: 50),
      assetUrl: '',
    ),
    Song(
      id: '2',
      title: 'Bohemian Rhapsody',
      artist: 'Queen',
      album: 'A Night At The Opera',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/4/4d/Queen_A_Night_At_The_Opera.png',
      duration: const Duration(minutes: 5, seconds: 55),
      assetUrl: '',
    ),
    Song(
      id: '3',
      title: 'Billie Jean',
      artist: 'Michael Jackson',
      album: 'Thriller',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/5/55/Michael_Jackson_-_Thriller.png',
      duration: const Duration(minutes: 4, seconds: 54),
      assetUrl: '',
    ),
    Song(
      id: '4',
      title: 'Do I Wanna Know?',
      artist: 'Arctic Monkeys',
      album: 'AM',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/0/04/Arctic_Monkeys_-_AM.png',
      duration: const Duration(minutes: 4, seconds: 32),
      assetUrl: '',
    ),
    Song(
      id: '5',
      title: 'Smells Like Teen Spirit',
      artist: 'Nirvana',
      album: 'Nevermind',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/b/b7/NirvanaNevermindalbumcover.jpg',
      duration: const Duration(minutes: 5, seconds: 1),
      assetUrl: '',
    ),
    Song(
      id: '6',
      title: 'Here Comes The Sun',
      artist: 'The Beatles',
      album: 'Abbey Road',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/4/42/Beatles_-_Abbey_Road.jpg',
      duration: const Duration(minutes: 3, seconds: 5),
      assetUrl: '',
    ),
    Song(
      id: '7',
      title: 'Money',
      artist: 'Pink Floyd',
      album: 'The Dark Side of the Moon',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/3/3b/Dark_Side_of_the_Moon.png',
      duration: const Duration(minutes: 6, seconds: 22),
      assetUrl: '',
    ),
    Song(
      id: '8',
      title: 'Get Lucky',
      artist: 'Daft Punk, Pharrell Williams',
      album: 'Random Access Memories',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/a/a7/Random_Access_Memories.jpg',
      duration: const Duration(minutes: 6, seconds: 9),
      assetUrl: '',
    ),
    Song(
      id: '9',
      title: 'Dreams',
      artist: 'Fleetwood Mac',
      album: 'Rumours',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/f/fb/FMacRumours.PNG',
      duration: const Duration(minutes: 4, seconds: 17),
      assetUrl: '',
    ),
    Song(
      id: '10',
      title: 'Still D.R.E.',
      artist: 'Dr. Dre, Snoop Dogg',
      album: '2001',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/c/c2/Dr.Dre-2001.jpg',
      duration: const Duration(minutes: 4, seconds: 30),
      assetUrl: '',
    ),
    Song(
      id: '11',
      title: 'The Less I Know The Better',
      artist: 'Tame Impala',
      album: 'Currents',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/9/9b/Tame_Impala_-_Currents.png',
      duration: const Duration(minutes: 3, seconds: 36),
      assetUrl: '',
    ),
    Song(
      id: '12',
      title: 'Levitating',
      artist: 'Dua Lipa',
      album: 'Future Nostalgia',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/f/f5/Dua_Lipa_-_Future_Nostalgia_%28Official_Album_Cover%29.png',
      duration: const Duration(minutes: 3, seconds: 23),
      assetUrl: '',
    ),
    Song(
      id: '13',
      title: 'In The End',
      artist: 'Linkin Park',
      album: 'Hybrid Theory',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/2/2a/Linkin_Park_Hybrid_Theory_Album_Cover.jpg',
      duration: const Duration(minutes: 3, seconds: 36),
      assetUrl: '',
    ),
    Song(
      id: '14',
      title: 'Feel Good Inc.',
      artist: 'Gorillaz',
      album: 'Demon Days',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/d/df/Gorillaz_Demon_Days.PNG',
      duration: const Duration(minutes: 3, seconds: 41),
      assetUrl: '',
    ),
  ];

  static final List<Album> albums = [
    Album(
      id: '1',
      title: '1 (Remastered)',
      artist: 'The Beatles',
      coverUrl:
          'https://i.scdn.co/image/ab67616d0000b273e64798f82300126f399a7531',
      songs: songs.where((s) => s.artist == 'The Beatles').toList(),
    ),
  ];

  static final List<Playlist> playlists = [
    Playlist(
      id: '1',
      title: 'Your Top Songs 2021',
      creator: 'Spotify',
      coverUrl:
          'https://misc.scdn.co/liked-songs/liked-songs-300.png', // Placeholder
      songs: songs,
    ),
    Playlist(
      id: '2',
      title: 'Indie Pop',
      creator: 'Spotify',
      coverUrl:
          'https://i.scdn.co/image/ab67616d0000b2739613a049320413c9d804599d', // Placeholder
      songs: [songs[0], songs[4]],
    ),
    Playlist(
      id: '3',
      title: 'This Is The Beatles',
      creator: 'Spotify',
      coverUrl:
          'https://thisis-images.scdn.co/37i9dQZF1DZ06evO1i2aC7-large.jpg',
      songs: songs.where((s) => s.artist == 'The Beatles').toList(),
    ),
  ];

  static final List<Artist> artists = [
    Artist(
      id: '1',
      name: 'The Beatles',
      imageUrl:
          'https://i.scdn.co/image/ab6761610000e5eb43a61c5b54625924779f2e06',
    ),
    Artist(
      id: '2',
      name: 'Lana Del Rey',
      imageUrl:
          'https://i.scdn.co/image/ab6761610000e5ebb99cacf8acd5378206767261',
    ),
    Artist(
      id: '3',
      name: 'Troye Sivan',
      imageUrl:
          'https://i.scdn.co/image/ab6761610000e5eb44873a5d3f0f7e6e326980a2',
    ),
  ];

  static final List<Playlist> recentlyPlayed = [
    playlists[0],
    playlists[1],
    playlists[2],
  ];

  static final List<Playlist> yourShows = [
    Playlist(
      id: 'p1',
      title: 'The Daily',
      creator: 'The New York Times',
      coverUrl:
          'https://i.scdn.co/image/ab6765630000ba8a045535125e36ca547b67131c',
      songs: [],
    ),
    Playlist(
      id: 'p2',
      title: 'TED Talks Daily',
      creator: 'TED',
      coverUrl:
          'https://i.scdn.co/image/ab6765630000ba8a150250517c519e3919342105',
      songs: [],
    ),
  ];
}
