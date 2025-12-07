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
  final String? message;

  const PlayerState({
    this.currentSong,
    this.isLiked = false,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isInitialBuffer = false,
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
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      isLiked: isLiked ?? this.isLiked,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isInitialBuffer: isInitialBuffer ?? this.isInitialBuffer,
      message: message ?? this.message,
    );
  }
}
