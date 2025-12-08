import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState, PlayerEvent;
import 'package:spotifly/core/youtube_user_agent.dart';
import 'package:spotifly/features/player/domain/usecases/add_song_to_liked.dart';
import 'package:spotifly/features/player/domain/usecases/get_audio_stream.dart';
import 'package:spotifly/features/player/domain/usecases/is_song_liked.dart';
import 'package:spotifly/features/player/domain/usecases/remove_song_from_liked.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayer _audioPlayer;
  final GetAudioStream _getAudioStream;
  final AddSongToLiked _addSongToLiked;
  final RemoveSongFromLiked _removeSongFromLiked;
  final IsSongLiked _isSongLiked;

  PlayerBloc({
    required GetAudioStream getAudioStream,
    required AddSongToLiked addSongToLiked,
    required RemoveSongFromLiked removeSongFromLiked,
    required IsSongLiked isSongLiked,
  }) : _audioPlayer = AudioPlayer(userAgent: YoutubeUserAgent.userAgent),
       _getAudioStream = getAudioStream,
       _addSongToLiked = addSongToLiked,
       _removeSongFromLiked = removeSongFromLiked,
       _isSongLiked = isSongLiked,
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

    on<CheckLikedStatus>((event, emit) async {
      try {
        final isLiked = await _isSongLiked(event.songId);
        emit(state.copyWith(isLiked: isLiked));
      } catch (e) {
        log("Error checking liked status: $e");
      }
    });

    on<ToggleLikeStatus>((event, emit) async {
      final song = state.currentSong;
      if (song == null) return;

      try {
        if (state.isLiked) {
          await _removeSongFromLiked(song.id);
          emit(
            state.copyWith(isLiked: false, message: "Removed from Liked Songs"),
          );
        } else {
          if (state.currentSong != null) {
            await _addSongToLiked(state.currentSong!);
            emit(
              state.copyWith(isLiked: true, message: "Added to Liked Songs"),
            );
          }
        }
      } catch (e) {
        log("Error toggling like status: $e");
      }
    });

    on<SetSongEvent>((event, emit) async {
      // Update metadata immediately
      emit(
        state.copyWith(
          currentSong: event.song,
          isPlaying: true,
          isInitialBuffer: true,
        ),
      );
      add(CheckLikedStatus(event.song.id));

      try {
        // Use the song metadata to find the audio stream
        final audioUrl = await _getAudioStream(
          event.song.title,
          event.song.artist,
        );
        await _audioPlayer.setUrl(audioUrl);
        emit(state.copyWith(isInitialBuffer: false));
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
