import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState, PlayerEvent;
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayer _audioPlayer;

  PlayerBloc() : _audioPlayer = AudioPlayer(), super(const PlayerState()) {
    _setupStreams();

    on<PlayEvent>((event, emit) => _audioPlayer.play());
    on<PauseEvent>((event, emit) => _audioPlayer.pause());
    on<TogglePlayEvent>((event, emit) {
      if (_audioPlayer.playing) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.play();
      }
    });

    on<SetSongEvent>((event, emit) async {
      // Update metadata immediately
      emit(state.copyWith(currentSong: event.song, isPlaying: true));

      try {
        // Play the mock URL as requested, regardless of the song
        const mockUrl =
            'https://filesamples.com/samples/audio/mp3/Symphony%20No.6%20(1st%20movement).mp3';
        await _audioPlayer.setUrl(mockUrl);
        _audioPlayer.play();
      } catch (e) {
        // In a real app, we would handle errors properly
        print("Error loading audio: $e");
      }
    });

    on<SeekEvent>((event, emit) => _audioPlayer.seek(event.position));

    on<UpdatePositionEvent>(
      (event, emit) => emit(state.copyWith(position: event.position)),
    );
    on<UpdateDurationEvent>(
      (event, emit) => emit(state.copyWith(duration: event.duration)),
    );
    on<UpdateIsPlayingEvent>(
      (event, emit) => emit(state.copyWith(isPlaying: event.isPlaying)),
    );
  }

  void _setupStreams() {
    _audioPlayer.positionStream.listen((position) {
      add(UpdatePositionEvent(position));
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        add(UpdateDurationEvent(duration));
      }
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      add(UpdateIsPlayingEvent(playerState.playing));
    });
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
