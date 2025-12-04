import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc()
    : super(PlayerState(currentSong: null, duration: Duration.zero)) {
    on<PlayEvent>((event, emit) => emit(state.copyWith(isPlaying: true)));
    on<PauseEvent>((event, emit) => emit(state.copyWith(isPlaying: false)));
    on<TogglePlayEvent>(
      (event, emit) => emit(state.copyWith(isPlaying: !state.isPlaying)),
    );
    on<SetSongEvent>(
      (event, emit) => emit(
        state.copyWith(
          currentSong: event.song,
          duration: event.song.duration,
          position: Duration.zero,
          isPlaying: true,
        ),
      ),
    );
    on<SeekEvent>(
      (event, emit) => emit(state.copyWith(position: event.position)),
    );
  }
}
