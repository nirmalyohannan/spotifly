import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotifly/core/youtube_user_agent.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final _player = AudioPlayer(userAgent: YoutubeUserAgent.userAgent);

  AudioPlayerHandler() {
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
      } catch (e) {
        log("Error playing audio: $e");
      }
    }
  }

  // Custom method to set URL and metadata (kept for flexibility but playMediaItem is preferred)
  Future<void> playUrl(String url, MediaItem item) async {
    return playMediaItem(item.copyWith(extras: {'url': url}));
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
}
