import 'dart:developer';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotifly/core/youtube_user_agent.dart';
import 'package:spotifly/features/home/domain/repositories/home_repository.dart';
import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final _player = AudioPlayer(userAgent: YoutubeUserAgent.userAgent);
  final HomeRepository _homeRepository;
  final PlaylistRepository _playlistRepository;

  AudioPlayerHandler(this._homeRepository, this._playlistRepository) {
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
        stop();
      }
    });
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      playbackState.value.copyWith(
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
        androidCompactActionIndices: const [0, 1, 3],
        processingState: _getProcessingState,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  // Get Current processing state
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

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() async => customEvent.add('skipToNext');

  @override
  Future<void> skipToPrevious() async => customEvent.add('skipToPrevious');

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
    final url = mediaItem.extras?['url'] as String?;
    if (url != null) {
      try {
        await _player.setUrl(url);
        play();
      } on SocketException catch (e) {
        log("Error playing audio: $e");
      } catch (e) {
        log("Error playing audio: $e");
      }
    }
  }

  Future<MediaItem?> getItem(String mediaId) async {
    // For now, we mainly use this for playable items or simple retrieval.
    // In a real app, you'd likely fetch from a repo based on ID.
    // Returning a dummy item or implementing proper lookup logic is needed.
    // For simplicity, we might just return the item if it's already in the queue,
    // or try to fetch it if possible.
    // For this implementation, we will try to find it in the current queue,
    // or return a default placeholder if not found, to avoid crashing.
    final queue = this.queue.value;
    try {
      final item = queue.firstWhere((element) => element.id == mediaId);
      return item;
    } catch (e) {
      return null;
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
          return songs
              .map(
                (song) => MediaItem(
                  id: song.id,
                  title: song.title,
                  artist: song.artist,
                  artUri: Uri.parse(song.coverUrl),
                  extras: {'url': song.assetUrl},
                  playable: true,
                ),
              )
              .toList();
        case 'playlists':
          final playlists = await _playlistRepository.getPlaylists();
          return playlists
              .map(
                (playlist) => MediaItem(
                  id: playlist.id,
                  title: playlist.title,
                  artUri: Uri.tryParse(playlist.coverUrl),
                  playable: false,
                ),
              )
              .toList();
        case 'liked':
          final songs = await _playlistRepository.likedSongsStream.first;
          return songs
              .map(
                (song) => MediaItem(
                  id: song.id,
                  title: song.title,
                  artist: song.artist,
                  artUri: Uri.parse(song.coverUrl),
                  extras: {'url': song.assetUrl},
                  playable: true,
                ),
              )
              .toList();
        default:
          // Assume it's a playlist ID
          final playlist = await _playlistRepository.getPlaylistById(
            parentMediaId,
          );
          if (playlist != null) {
            return playlist.songs
                .map(
                  (song) => MediaItem(
                    id: song.id,
                    title: song.title,
                    artist: song.artist,
                    artUri: Uri.parse(song.coverUrl),
                    extras: {'url': song.assetUrl},
                    playable: true,
                  ),
                )
                .toList();
          }
          return [];
      }
    } catch (e) {
      log("Error in getChildren: $e");
      return [];
    }
  }

  // Custom method to set URL and metadata (kept for flexibility but playMediaItem is preferred)
  Future<void> playUrl(String url, MediaItem item) async {
    return playMediaItem(item.copyWith(extras: {'url': url}));
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
}
