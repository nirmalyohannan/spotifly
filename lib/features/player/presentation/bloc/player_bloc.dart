import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/services/audio_player_handler.dart';
import 'package:spotifly/features/player/domain/usecases/add_song_to_liked.dart';
import 'package:spotifly/features/player/domain/usecases/get_audio_stream.dart';
import 'package:spotifly/features/player/domain/usecases/is_song_liked.dart';
import 'package:spotifly/features/player/domain/usecases/remove_song_from_liked.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioHandler _audioHandler;
  final GetAudioStream _getAudioStream;
  final AddSongToLiked _addSongToLiked;
  final RemoveSongFromLiked _removeSongFromLiked;
  final IsSongLiked _isSongLiked;

  PlayerBloc({
    required AudioHandler audioHandler,
    required GetAudioStream getAudioStream,
    required AddSongToLiked addSongToLiked,
    required RemoveSongFromLiked removeSongFromLiked,
    required IsSongLiked isSongLiked,
  }) : _audioHandler = audioHandler,
       _getAudioStream = getAudioStream,
       _addSongToLiked = addSongToLiked,
       _removeSongFromLiked = removeSongFromLiked,
       _isSongLiked = isSongLiked,
       super(const PlayerState()) {
    _setupStreams();

    on<PlayEvent>((event, emit) => _audioHandler.play());
    on<PauseEvent>((event, emit) => _audioHandler.pause());
    on<TogglePlayEvent>(_onTogglePlayEvent);
    on<CheckLikedStatus>(_onCheckLikedStatus);

    on<ToggleLikeStatus>(_onToggleLikeStatus);

    on<SetSongEvent>(_onSetSongEvent);

    on<SeekEvent>((event, emit) => _audioHandler.seek(event.position));

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

    on<ToggleShuffleModeEvent>(_onToggleShuffleMode);
    on<ToggleRepeatModeEvent>(_onToggleRepeatMode);
  }

  FutureOr<void> _onToggleLikeStatus(
    ToggleLikeStatus event,
    Emitter<PlayerState> emit,
  ) async {
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
          emit(state.copyWith(isLiked: true, message: "Added to Liked Songs"));
        }
      }
    } catch (e) {
      log("Error toggling like status: $e");
    }
  }

  FutureOr<void> _onCheckLikedStatus(
    CheckLikedStatus event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      final isLiked = await _isSongLiked(event.songId);
      emit(state.copyWith(isLiked: isLiked));
    } catch (e) {
      log("Error checking liked status: $e");
    }
  }

  FutureOr<void> _onTogglePlayEvent(
    TogglePlayEvent event,
    Emitter<PlayerState> emit,
  ) {
    if (state.isPlaying) {
      _audioHandler.pause();
    } else {
      _audioHandler.play();
    }
  }

  FutureOr<void> _onSetSongEvent(
    SetSongEvent event,
    Emitter<PlayerState> emit,
  ) async {
    // Update metadata immediately
    emit(
      state.copyWith(
        currentSong: event.song,
        isPlaying: true, // Will update via stream, but optimistic update
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

      final mediaItem = MediaItem(
        id: event.song.id,
        title: event.song.title,
        artist: event.song.artist,
        album: event.song.album,
        artUri: Uri.parse(event.song.coverUrl),
        duration: event.song.duration,
        extras: {'url': audioUrl},
      );

      await _audioHandler.playMediaItem(mediaItem);
      emit(state.copyWith(isInitialBuffer: false));
    } catch (e) {
      // In a real app, we would handle errors properly
      log("Error loading audio: $e");
    }
  }

  void _setupStreams() {
    _audioHandler.playbackState.listen((playbackState) {
      add(UpdateIsPlayingEvent(playbackState.playing));
      if (playbackState.processingState == AudioProcessingState.completed) {
        add(PlayerCompleteEvent());
      }
    });

    _audioHandler.customEvent.listen((event) {
      switch (event) {
        case 'skipToNext':
          add(PlayNextEvent());
          break;
        case 'skipToPrevious':
          add(PlayPreviousEvent());
          break;
      }
    });

    // Access specific streams from our handler implementation
    if (_audioHandler is AudioPlayerHandler) {
      final handler = _audioHandler as AudioPlayerHandler;
      handler.positionStream.listen((position) {
        add(UpdatePositionEvent(position));
      });
      handler.durationStream.listen((duration) {
        if (duration != null) {
          add(UpdateDurationEvent(duration));
        }
      });
    }
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
    if (state.position.inSeconds > 3) {
      _audioHandler.seek(Duration.zero);
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

  Future<void> _onToggleShuffleMode(
    ToggleShuffleModeEvent event,
    Emitter<PlayerState> emit,
  ) async {
    final isShuffleMode = !state.isShuffleMode;
    final List<Song> queue;
    int currentIndex;
    if (isShuffleMode) {
      if (state.queue.isEmpty) return;
      //Logic to shuffle the queue without changing the current song
      queue = List.from(state.originalQueue);
      queue.removeAt(state.currentIndex);
      queue.shuffle();
      queue.insert(0, state.currentSong!);
      currentIndex = 0;
    } else {
      queue = List.from(state.originalQueue);
      //find the index of the current song
      if (state.currentSong != null) {
        currentIndex = queue.indexOf(state.currentSong!);
        // If song not found (shouldn't happen), fallback to 0
        if (currentIndex == -1) currentIndex = 0;
      } else {
        currentIndex = 0;
      }
    }

    emit(
      state.copyWith(
        isShuffleMode: isShuffleMode,
        queue: queue,
        currentIndex: currentIndex,
      ),
    );
  }

  Future<void> _onToggleRepeatMode(
    ToggleRepeatModeEvent event,
    Emitter<PlayerState> emit,
  ) async {
    emit(state.copyWith(isRepeatMode: !state.isRepeatMode));
  }

  @override
  Future<void> close() {
    // _audioHandler is singleton, do not dispose it here
    return super.close();
  }
}
