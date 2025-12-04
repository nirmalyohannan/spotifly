import 'package:meta/meta.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

@immutable
abstract class PlayerEvent {}

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
