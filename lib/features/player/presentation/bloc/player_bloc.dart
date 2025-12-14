import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/services/audio_player_handler.dart';
import 'package:spotifly/core/utils/logger.dart';
import 'package:spotifly/features/player/domain/usecases/add_song_to_liked.dart';
import 'package:spotifly/features/player/domain/usecases/is_song_liked.dart';
import 'package:spotifly/features/player/domain/usecases/remove_song_from_liked.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioHandler _audioHandler;
  final AddSongToLiked _addSongToLiked;
  final RemoveSongFromLiked _removeSongFromLiked;
  final IsSongLiked _isSongLiked;

  PlayerBloc({
    required AudioHandler audioHandler,
    required AddSongToLiked addSongToLiked,
    required RemoveSongFromLiked removeSongFromLiked,
    required IsSongLiked isSongLiked,
  }) : _audioHandler = audioHandler,
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

    on<UpdateQueueEvent>((event, emit) {
      emit(state.copyWith(queue: event.queue));
    });

    on<UpdateCurrentSongEvent>((event, emit) {
      emit(state.copyWith(currentSong: event.song));
      add(CheckLikedStatus(event.song.id));
    });

    on<UpdateIndexEvent>((event, emit) {
      emit(state.copyWith(currentIndex: event.index));
    });

    on<UpdateRepeatModeEvent>(
      (event, emit) => emit(state.copyWith(repeatMode: event.mode)),
    );
    on<UpdateShuffleModeEvent>(
      (event, emit) => emit(state.copyWith(isShuffleMode: event.isShuffleMode)),
    );

    on<SetPlaylistEvent>(_onSetPlaylist);

    on<PlayNextEvent>((event, emit) => _audioHandler.skipToNext());
    on<PlayPreviousEvent>((event, emit) => _audioHandler.skipToPrevious());

    on<SetSongEvent>((event, emit) async {
      final mediaItem = _songToMediaItem(event.song);
      await _audioHandler.playMediaItem(mediaItem);
    });

    on<ToggleShuffleModeEvent>(_onToggleShuffleMode);
    on<ToggleRepeatModeEvent>(_onToggleRepeatMode);

    on<PlayerCompleteEvent>((event, emit) {});

    on<ResetPlayer>(_onResetPlayer);
  }

  FutureOr<void> _onResetPlayer(
    ResetPlayer event,
    Emitter<PlayerState> emit,
  ) async {
    await _audioHandler.stop();
    emit(const PlayerState());
  }

  void _setupStreams() {
    _audioHandler.playbackState.listen((playbackState) {
      add(UpdateIsPlayingEvent(playbackState.playing));

      if (playbackState.queueIndex != null) {
        add(UpdateIndexEvent(playbackState.queueIndex!));
      }

      final repeatMode = _mapRepeatMode(playbackState.repeatMode);
      add(UpdateRepeatModeEvent(repeatMode));

      final isShuffle =
          playbackState.shuffleMode == AudioServiceShuffleMode.all;
      add(UpdateShuffleModeEvent(isShuffle));
    });

    _audioHandler.queue.listen((mediaItems) {
      final songs = mediaItems.map(_mediaItemToSong).toList();
      add(UpdateQueueEvent(songs));
    });

    _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        add(UpdateCurrentSongEvent(_mediaItemToSong(mediaItem)));
      }
    });

    if (_audioHandler is AudioPlayerHandler) {
      final handler = _audioHandler;
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
      Logger.e("PlayerBloc: Error toggling like status: $e");
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
      Logger.e("PlayerBloc: Error checking liked status: $e");
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

  Future<void> _onSetPlaylist(
    SetPlaylistEvent event,
    Emitter<PlayerState> emit,
  ) async {
    if (_audioHandler is AudioPlayerHandler) {
      final handler = _audioHandler;
      final mediaItems = event.songs.map(_songToMediaItem).toList();

      if (event.isShuffle) {
        await handler.setShuffleMode(AudioServiceShuffleMode.all);
      } else {
        await handler.setShuffleMode(AudioServiceShuffleMode.none);
      }

      await handler.setQueue(mediaItems, initialIndex: event.initialIndex);
    }
  }

  Future<void> _onToggleShuffleMode(
    ToggleShuffleModeEvent event,
    Emitter<PlayerState> emit,
  ) async {
    // Toggle logic
    final newMode = !state.isShuffleMode;
    final mode = newMode
        ? AudioServiceShuffleMode.all
        : AudioServiceShuffleMode.none;
    await _audioHandler.setShuffleMode(mode);
  }

  Future<void> _onToggleRepeatMode(
    ToggleRepeatModeEvent event,
    Emitter<PlayerState> emit,
  ) async {
    final current = state.repeatMode;
    final next = _getNextRepeatMode(current);

    AudioServiceRepeatMode mode;
    switch (next) {
      case PlayerRepeatMode.off:
        mode = AudioServiceRepeatMode.none;
        break;
      case PlayerRepeatMode.all:
        mode = AudioServiceRepeatMode.all;
        break;
      case PlayerRepeatMode.one:
        mode = AudioServiceRepeatMode.one;
        break;
    }
    await _audioHandler.setRepeatMode(mode);
  }

  PlayerRepeatMode _getNextRepeatMode(PlayerRepeatMode current) {
    switch (current) {
      case PlayerRepeatMode.off:
        return PlayerRepeatMode.all;
      case PlayerRepeatMode.all:
        return PlayerRepeatMode.one;
      case PlayerRepeatMode.one:
        return PlayerRepeatMode.off;
    }
  }

  PlayerRepeatMode _mapRepeatMode(AudioServiceRepeatMode mode) {
    switch (mode) {
      case AudioServiceRepeatMode.none:
        return PlayerRepeatMode.off;
      case AudioServiceRepeatMode.all:
        return PlayerRepeatMode.all;
      case AudioServiceRepeatMode.one:
        return PlayerRepeatMode.one;
      default:
        return PlayerRepeatMode.off;
    }
  }

  Song _mediaItemToSong(MediaItem item) {
    return Song(
      id: item.id,
      title: item.title,
      artist: item.artist ?? '',
      album: item.album ?? '',
      coverUrl: item.artUri?.toString() ?? '',
      duration: item.duration ?? Duration.zero,
      assetUrl: item.extras?['url'] ?? '',
    );
  }

  MediaItem _songToMediaItem(Song song) {
    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      artUri: Uri.tryParse(song.coverUrl),
      duration: song.duration,
      extras: {'url': song.assetUrl},
    );
  }
}
