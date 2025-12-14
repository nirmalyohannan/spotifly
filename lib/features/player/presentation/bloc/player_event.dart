import 'package:meta/meta.dart';
import 'package:spotifly/shared/domain/entities/song.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';

@immutable
abstract class PlayerEvent {}

class ResetPlayer extends PlayerEvent {}

class PlayEvent extends PlayerEvent {}

class PauseEvent extends PlayerEvent {}

class TogglePlayEvent extends PlayerEvent {}

class SetSongEvent extends PlayerEvent {
  final Song song;

  SetSongEvent(this.song);
}

class SeekEvent extends PlayerEvent {
  final Duration position;

  SeekEvent(this.position);
}

class UpdatePositionEvent extends PlayerEvent {
  final Duration position;

  UpdatePositionEvent(this.position);
}

class UpdateDurationEvent extends PlayerEvent {
  final Duration duration;

  UpdateDurationEvent(this.duration);
}

class UpdateIsPlayingEvent extends PlayerEvent {
  final bool isPlaying;

  UpdateIsPlayingEvent(this.isPlaying);
}

class ToggleLikeStatus extends PlayerEvent {}

class CheckLikedStatus extends PlayerEvent {
  final String songId;
  CheckLikedStatus(this.songId);
}

class SetPlaylistEvent extends PlayerEvent {
  final List<Song> songs;
  final int initialIndex;
  final bool isShuffle;

  SetPlaylistEvent({
    required this.songs,
    this.initialIndex = 0,
    this.isShuffle = false,
  });
}

class PlayNextEvent extends PlayerEvent {}

class PlayPreviousEvent extends PlayerEvent {}

class PlayerCompleteEvent extends PlayerEvent {}

class ToggleShuffleModeEvent extends PlayerEvent {}

class ToggleRepeatModeEvent extends PlayerEvent {}

// Internal Events for syncing with AudioService
class UpdateQueueEvent extends PlayerEvent {
  final List<Song> queue;
  UpdateQueueEvent(this.queue);
}

class UpdateCurrentSongEvent extends PlayerEvent {
  final Song song;
  UpdateCurrentSongEvent(this.song);
}

class UpdateIndexEvent extends PlayerEvent {
  final int index;
  UpdateIndexEvent(this.index);
}

class UpdateRepeatModeEvent extends PlayerEvent {
  final PlayerRepeatMode mode;
  UpdateRepeatModeEvent(this.mode);
}

class UpdateShuffleModeEvent extends PlayerEvent {
  final bool isShuffleMode;
  UpdateShuffleModeEvent(this.isShuffleMode);
}
