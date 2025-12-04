import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState, PlayerEvent;
import 'package:spotifly/core/youtube_user_agent.dart';
import 'package:spotifly/features/player/domain/usecases/get_audio_stream.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayer _audioPlayer;
  final GetAudioStream _getAudioStream;

  PlayerBloc({required GetAudioStream getAudioStream})
    : _audioPlayer = AudioPlayer(userAgent: YoutubeUserAgent.userAgent),
      _getAudioStream = getAudioStream,
      super(const PlayerState()) {
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
        // Use the mock video URL as requested
        const mockVideoUrl = "https://www.youtube.com/watch?v=kffacxfA7G4";
        final videoId = VideoId(mockVideoUrl);

        final audioUrl = await _getAudioStream(videoId.value);
        await _audioPlayer.setUrl(audioUrl);
        _audioPlayer.play();
      } catch (e) {
        // In a real app, we would handle errors properly
        log("Error loading audio: $e");
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
