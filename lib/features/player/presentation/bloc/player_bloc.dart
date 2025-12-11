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
import 'package:spotifly/shared/domain/entities/song.dart';

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

    // Playlist Events
    on<SetPlaylistEvent>(_onSetPlaylist);
    on<PlayNextEvent>(_onPlayNext);
    on<PlayPreviousEvent>(_onPlayPrevious);
    on<PlayerCompleteEvent>((event, emit) => add(PlayNextEvent()));
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
      if (playerState.processingState == ProcessingState.completed) {
        add(PlayerCompleteEvent());
      }
    });
  }

  Future<void> _onSetPlaylist(
    SetPlaylistEvent event,
    Emitter<PlayerState> emit,
  ) async {
    final List<Song> originalQueue = List.from(event.songs);
    List<Song> queue = List.from(event.songs);
    int currentIndex = event.initialIndex;

    if (event.isShuffle) {
      // shuffle logic:
      // 1. Get the starting song
      final startingSong = queue[currentIndex];
      // 2. Remove it from the list to be shuffled
      queue.removeAt(currentIndex);
      // 3. Shuffle the rest
      queue.shuffle();
      // 4. Insert starting song at the beginning
      queue.insert(0, startingSong);
      // 5. Set current index to 0
      currentIndex = 0;
    }

    emit(
      state.copyWith(
        originalQueue: originalQueue,
        queue: queue,
        currentIndex: currentIndex,
        isShuffleMode: event.isShuffle,
        isRepeatMode: false,
      ),
    );

    if (queue.isNotEmpty) {
      add(SetSongEvent(queue[currentIndex]));
    }
  }

  Future<void> _onPlayNext(
    PlayNextEvent event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.queue.isEmpty) return;

    int nextIndex = state.currentIndex + 1;

    // Handle end of playlist
    if (nextIndex >= state.queue.length) {
      if (state.isRepeatMode) {
        nextIndex = 0;
      } else {
        // Stop playing if not repeat mode
        return;
      }
    }

    emit(state.copyWith(currentIndex: nextIndex));
    add(SetSongEvent(state.queue[nextIndex]));
  }

  Future<void> _onPlayPrevious(
    PlayPreviousEvent event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.queue.isEmpty) return;

    // If more than 3 seconds in, restart current song
    if (_audioPlayer.position.inSeconds > 3) {
      _audioPlayer.seek(Duration.zero);
      return;
    }

    int prevIndex = state.currentIndex - 1;

    if (prevIndex < 0) {
      if (state.isRepeatMode) {
        prevIndex = state.queue.length - 1;
      } else {
        prevIndex = 0; // Stay at first song
      }
    }

    emit(state.copyWith(currentIndex: prevIndex));
    add(SetSongEvent(state.queue[prevIndex]));
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
