
import 'package:meta/meta.dart';
import '../../domain/entities/song.dart';

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
