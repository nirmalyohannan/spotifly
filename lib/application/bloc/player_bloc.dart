
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/application/bloc/player_event.dart';
import 'package:spotifly/application/bloc/player_state.dart';
import 'package:spotifly/data/repositories/mock_data.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(PlayerState(currentSong: MockData.songs[0], duration: MockData.songs[0].duration)) {
    on<PlayEvent>((event, emit) => emit(state.copyWith(isPlaying: true)));
    on<PauseEvent>((event, emit) => emit(state.copyWith(isPlaying: false)));
    on<TogglePlayEvent>((event, emit) => emit(state.copyWith(isPlaying: !state.isPlaying)));
    on<SetSongEvent>((event, emit) => emit(state.copyWith(currentSong: event.song, duration: event.song.duration, position: Duration.zero, isPlaying: true)));
    on<SeekEvent>((event, emit) => emit(state.copyWith(position: event.position)));
  }
}
