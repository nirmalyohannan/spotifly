import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotifly/core/youtube_user_agent.dart';
import 'package:spotifly/features/home/domain/repositories/home_repository.dart';
import 'package:spotifly/features/player/domain/repositories/player_repository.dart';
import 'package:spotifly/shared/domain/entities/song.dart';
import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';
import 'package:spotifly/features/player/domain/repositories/audio_cache_repository.dart';
import 'package:spotifly/features/player/data/datasources/caching_stream_audio_source.dart';
import 'package:spotifly/features/player/domain/entities/cache_source.dart';
import 'package:spotifly/features/player/data/models/cached_song_metadata.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer(
    userAgent: YoutubeUserAgent.userAgent,
  );
  final HomeRepository _homeRepository;
  final PlaylistRepository _playlistRepository;
  final PlayerRepository _playerRepository;
  final AudioCacheRepository _audioCacheRepository;

  // Internal queue management
  List<MediaItem> _queue = [];
  List<MediaItem> _originalQueue = [];
  int _currentIndex = 0;
  bool _isShuffleMode = false;
  AudioServiceRepeatMode _repeatMode = AudioServiceRepeatMode.none;

  // Cache for Android Auto browsing
  final _songCache = <String, Song>{};
  //This will be used to store the last browsed media items
  //So when a song is tapped in Android Auto, the remaining songs can be set in Queue from this list
  //Without this, the queue will be empty when a song is tapped in Android Auto
  List<MediaItem> _lastBrowsedMediaItems = [];

  AudioPlayerHandler(
    this._homeRepository,
    this._playlistRepository,
    this._playerRepository,
    this._audioCacheRepository,
  ) {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Broadcast state changes
    _player.playbackEventStream.listen(_broadcastState);

    // Propagate processing state to playback state
    _player.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        _onPlaybackComplete();
      }
    });

    // Listen to duration changes
    _player.durationStream.listen((duration) {
      final currentItem = mediaItem.value;
      if (duration != null && currentItem != null) {
        // Only update if duration has changed
        if (currentItem.duration != duration) {
          mediaItem.add(currentItem.copyWith(duration: duration));
        }
      }
    });
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _getProcessingState,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _currentIndex,
        shuffleMode: _isShuffleMode
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        repeatMode: _repeatMode,
        updateTime: DateTime.now(),
      ),
    );
  }

  AudioProcessingState get _getProcessingState {
    final processingStateMap = {
      ProcessingState.idle: AudioProcessingState.idle,
      ProcessingState.loading: AudioProcessingState.loading,
      ProcessingState.buffering: AudioProcessingState.buffering,
      ProcessingState.ready: AudioProcessingState.ready,
      ProcessingState.completed: AudioProcessingState.completed,
    };
    return processingStateMap[_player.processingState]!;
  }

  Future<void> _onPlaybackComplete() async {
    if (_repeatMode == AudioServiceRepeatMode.one) {
      await seek(Duration.zero);
      await play();
    } else {
      await skipToNext();
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;

    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
    } else {
      // End of queue
      if (_repeatMode == AudioServiceRepeatMode.all) {
        _currentIndex = 0;
      } else {
        // For Repeat None and One, manual next at end of queue
        // typically loops for One? No, One loops on itself.
        // If user clicks Next on the last song in Repeat One:
        // Spotify: goes to first song (wraps).
        // Let's wrap if Repeat All or One.
        // Actually if Repeat One, we usually want to go to next song (effectively wrap to start if 1 song, or go to next index).
        // But here we are at end.
        if (_repeatMode == AudioServiceRepeatMode.one) {
          _currentIndex = 0;
        } else {
          // Repeat None
          await stop();
          return;
        }
      }
    }

    await _playCurrent();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;

    // If more than 3 seconds in, restart current song
    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      if (_repeatMode == AudioServiceRepeatMode.all ||
          _repeatMode == AudioServiceRepeatMode.one) {
        _currentIndex = _queue.length - 1;
      } else {
        _currentIndex = 0;
      }
    }

    await _playCurrent();
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    await setQueue(queue);
  }

  Future<void> setQueue(
    List<MediaItem> newQueue, {
    int initialIndex = 0,
  }) async {
    _originalQueue = List.from(newQueue);
    _queue = List.from(newQueue);
    _currentIndex = initialIndex;

    if (_isShuffleMode) {
      if (_queue.isNotEmpty &&
          initialIndex >= 0 &&
          initialIndex < _queue.length) {
        final firstItem = _queue[initialIndex];
        _queue.removeAt(initialIndex);
        _queue.shuffle();
        _queue.insert(0, firstItem);
        _currentIndex = 0;
      }
    }

    queue.add(_queue); // Broadcast

    if (_queue.isNotEmpty &&
        _currentIndex >= 0 &&
        _currentIndex < _queue.length) {
      await _playCurrent();
    }
  }

  Future<void> _playCurrent() async {
    final mediaItem = _queue[_currentIndex];
    await playMediaItem(mediaItem);
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.loading,
        playing: false,
        updatePosition: Duration.zero,
        bufferedPosition: Duration.zero,
        speed: 1.0,
        queueIndex: _currentIndex,
        shuffleMode: _isShuffleMode
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        repeatMode: _repeatMode,
      ),
    );

    try {
      // 1. Check Cache
      final cachedMetadata = await _audioCacheRepository.getCachedSong(
        mediaItem.id,
      );
      if (cachedMetadata != null) {
        log("Cache Hit for ${mediaItem.title}: ${cachedMetadata.filePath}");
        final file = File(cachedMetadata.filePath);
        if (await file.exists()) {
          // Play from file
          await _player.setAudioSource(
            AudioSource.file(cachedMetadata.filePath),
          );
          await _player.play();
          return;
        } else {
          log("Cache file missing for ${mediaItem.title}");
        }
      }

      // 2. Cache Miss - Fetch URL
      final url = await _playerRepository.getAudioStreamUrl(
        mediaItem.title,
        mediaItem.artist ?? "",
      );

      if (url.isEmpty) {
        log("Could not resolve URL for ${mediaItem.title}");
        return;
      }

      final itemWithUrl = mediaItem.copyWith(extras: {'url': url});
      this.mediaItem.add(itemWithUrl);

      // 3. Prepare Caching Path
      final docsDir = await getApplicationDocumentsDirectory();
      // Sanitize filename to avoid issues
      final safeId = mediaItem.id.replaceAll(RegExp(r'[^\w\d]'), '_');
      final cachePath = '${docsDir.path}/audioCache/youtube/$safeId.mp3';

      // 4. Setup Source
      final source = CachingStreamAudioSource(
        uri: Uri.parse(url),
        filePath: cachePath,
        onDownloadComplete: (fileSize) async {
          // Save metadata
          final metadata = CachedSongMetadata(
            id: mediaItem.id,
            title: mediaItem.title,
            artist: mediaItem.artist ?? 'Unknown',
            album: mediaItem.album ?? 'Unknown',
            coverUrl: mediaItem.artUri?.toString() ?? '',
            durationMs: mediaItem.duration?.inMilliseconds ?? 0,
            remoteUrl: url,
            source: CacheSource.youtube,
            filePath: cachePath,
            lastPlayedAt: DateTime.now(),
            fileSize: fileSize,
          );
          await _audioCacheRepository.saveCachedSong(metadata);
        },
      );

      await _player.setAudioSource(source);
      await _player.play();
    } catch (e) {
      log("Error playing audio: $e");
    }
  }

  @override
  Future<void> playFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) async {
    log("playFromMediaId: $mediaId");

    final index = _queue.indexWhere((item) => item.id == mediaId);
    if (index != -1) {
      _currentIndex = index;
      await _playCurrent();
      return;
    }

    // Check if it's in the last browsed list (e.g. user clicked a song in Android Auto list)
    final browseIndex = _lastBrowsedMediaItems.indexWhere(
      (item) => item.id == mediaId,
    );
    if (browseIndex != -1) {
      await setQueue(_lastBrowsedMediaItems, initialIndex: browseIndex);
      return;
    }

    final song = _songCache[mediaId];
    if (song != null) {
      final mediaItem = MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        artUri: Uri.parse(song.coverUrl),
        duration: song.duration,
        album: song.album,
        playable: true,
      );
      await setQueue([mediaItem]);
    } else {
      log("Song not found in cache or queue: $mediaId");
    }
  }

  @override
  Future<List<MediaItem>> getChildren(
    String parentMediaId, [
    Map<String, dynamic>? options,
  ]) async {
    log("getChildren parentMediaId: $parentMediaId");
    try {
      switch (parentMediaId) {
        case AudioService.browsableRootId:
          return [
            const MediaItem(
              id: 'recent',
              title: "Recently Played",
              playable: false,
            ),
            const MediaItem(
              id: 'playlists',
              title: "Playlists",
              playable: false,
            ),
            const MediaItem(id: 'liked', title: "Liked Songs", playable: false),
          ];
        case 'recent':
          final songs = await _homeRepository.getRecentlyPlayed();
          for (var song in songs) {
            _songCache[song.id] = song;
          }
          final items = songs
              .map(
                (song) => MediaItem(
                  id: song.id,
                  title: song.title,
                  artist: song.artist,
                  artUri: Uri.parse(song.coverUrl),
                  duration: song.duration,
                  playable: true,
                ),
              )
              .toList();
          _lastBrowsedMediaItems = items;
          return items;
        case 'playlists':
          final playlists = await _playlistRepository.getPlaylists();
          return playlists
              .map(
                (playlist) => MediaItem(
                  id: "${playlist.id} ${playlist.snapshotId}", //both seperated by space
                  title: playlist.title,
                  artUri: Uri.tryParse(playlist.coverUrl),
                  playable: false,
                ),
              )
              .toList();
        case 'liked':
          final songs = await _playlistRepository.getLikedSongs();
          for (var song in songs) {
            _songCache[song.id] = song;
          }
          final items = songs
              .map(
                (song) => MediaItem(
                  id: song.id,
                  title: song.title,
                  artist: song.artist,
                  artUri: Uri.parse(song.coverUrl),
                  duration: song.duration,
                  playable: true,
                ),
              )
              .toList();
          _lastBrowsedMediaItems = items;
          return items;
        default:
          // id was concatenated with space in getChildren Playlist Switch Case
          final ids = parentMediaId.split(" ");
          final playlistId = ids[0];
          final playlistSnapshotId = ids.length > 1 ? ids[1] : null;

          final playlist = await _playlistRepository.getPlaylistById(
            playlistId,
            playlistSnapshotId,
          );
          if (playlist != null) {
            for (var song in playlist.songs) {
              _songCache[song.id] = song;
            }
            final items = playlist.songs
                .map(
                  (song) => MediaItem(
                    id: song.id,
                    title: song.title,
                    artist: song.artist,
                    artUri: Uri.parse(song.coverUrl),
                    duration: song.duration,
                    album: song.album,
                    playable: true,
                  ),
                )
                .toList();
            _lastBrowsedMediaItems = items;
            return items;
          }
          return [];
      }
    } catch (e) {
      log("Error in getChildren: $e");
      return [];
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final newShuffleMode = shuffleMode == AudioServiceShuffleMode.all;
    if (newShuffleMode == _isShuffleMode) return;

    _isShuffleMode = newShuffleMode;

    if (_queue.isEmpty) {
      // Just update state
      playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
      return;
    }

    if (_isShuffleMode) {
      // Shuffle ON
      final currentItem = _queue[_currentIndex];
      // Shuffle logic: Shuffle original, put current first
      _queue = List.from(_originalQueue);
      _queue.removeWhere((item) => item.id == currentItem.id);
      _queue.shuffle();
      _queue.insert(0, currentItem);
      _currentIndex = 0;
    } else {
      // Shuffle OFF
      final currentItem = _queue[_currentIndex];
      _queue = List.from(_originalQueue);
      final index = _queue.indexWhere((item) => item.id == currentItem.id);
      if (index != -1) {
        _currentIndex = index;
      } else {
        _currentIndex = 0;
      }
    }

    queue.add(_queue);
    playbackState.add(
      playbackState.value.copyWith(
        shuffleMode: shuffleMode,
        queueIndex: _currentIndex,
      ),
    );
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    _repeatMode = repeatMode;
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
}
