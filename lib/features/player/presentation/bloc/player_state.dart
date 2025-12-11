import 'package:meta/meta.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

@immutable
class PlayerState {
  final Song? currentSong;
  final bool isLiked;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isInitialBuffer;
  final List<Song> queue;
  final List<Song> originalQueue;
  final int currentIndex;
  final bool isShuffleMode;
  final bool isRepeatMode;
  final String? message;

  const PlayerState({
    this.currentSong,
    this.isLiked = false,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isInitialBuffer = false,
    this.queue = const [],
    this.originalQueue = const [],
    this.currentIndex = 0,
    this.isShuffleMode = false,
    this.isRepeatMode = false,
    this.message,
  });

  PlayerState copyWith({
    Song? currentSong,
    bool? isLiked,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    String? message,
    bool? isInitialBuffer,
    List<Song>? queue,
    List<Song>? originalQueue,
    int? currentIndex,
    bool? isShuffleMode,
    bool? isRepeatMode,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      isLiked: isLiked ?? this.isLiked,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isInitialBuffer: isInitialBuffer ?? this.isInitialBuffer,
      message: message ?? this.message,
      queue: queue ?? this.queue,
      originalQueue: originalQueue ?? this.originalQueue,
      currentIndex: currentIndex ?? this.currentIndex,
      isShuffleMode: isShuffleMode ?? this.isShuffleMode,
      isRepeatMode: isRepeatMode ?? this.isRepeatMode,
    );
  }
}
