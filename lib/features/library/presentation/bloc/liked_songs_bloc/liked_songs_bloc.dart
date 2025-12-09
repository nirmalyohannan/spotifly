import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/library/domain/use_cases/get_liked_songs.dart';
import 'package:spotifly/features/library/domain/use_cases/get_liked_songs_count.dart';
import 'package:spotifly/shared/domain/entities/song.dart';
import 'liked_songs_event.dart';
import 'liked_songs_state.dart';

class LikedSongsBloc extends Bloc<LikedSongsEvent, LikedSongsState> {
  final GetLikedSongs getLikedSongs;
  final GetLikedSongsCount getLikedSongsCount;

  LikedSongsBloc({
    required this.getLikedSongs,
    required this.getLikedSongsCount,
  }) : super(const LikedSongsState()) {
    on<LoadLikedSongs>(_onLoadLikedSongs);
    on<LikedSongsCountUpdated>(_onLikedSongsCountUpdated);
  }

  Future<void> _onLoadLikedSongs(
    LoadLikedSongs event,
    Emitter<LikedSongsState> emit,
  ) async {
    // Show loading initially
    if (state.status == LikedSongsStatus.initial) {
      emit(state.copyWith(status: LikedSongsStatus.loading));
    }

    // Trigger side-effect (get count and start sync) without awaiting the full stream logic (which is blocked by forEach)
    // We execute this concurrently
    getLikedSongsCount().then((count) {
      if (!emit.isDone) {
        add(LikedSongsCountUpdated(count));
      }
    });

    // Start listening to the stream of songs
    await emit.forEach<List<Song>>(
      getLikedSongs.stream,
      onData: (songs) {
        // Compute new total count safely
        // If we have more songs than current total, update total.
        int currentTotal = state.totalCount;
        if (songs.length > currentTotal) {
          currentTotal = songs.length;
        }

        return state.copyWith(
          status: LikedSongsStatus.success,
          songs: songs,
          totalCount: currentTotal,
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(
          status: LikedSongsStatus.failure,
          errorMessage: error.toString(),
        );
      },
    );
  }

  void _onLikedSongsCountUpdated(
    LikedSongsCountUpdated event,
    Emitter<LikedSongsState> emit,
  ) {
    emit(state.copyWith(totalCount: event.count));
  }
}
