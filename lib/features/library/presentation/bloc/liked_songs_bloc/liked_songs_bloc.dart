import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/library/domain/use_cases/get_liked_songs.dart';
import 'package:spotifly/features/library/domain/use_cases/get_liked_songs_count.dart';
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
    on<LoadMoreLikedSongs>(_onLoadMoreLikedSongs);
  }

  Future<void> _onLoadLikedSongs(
    LoadLikedSongs event,
    Emitter<LikedSongsState> emit,
  ) async {
    // If we already have data, don't reset completely, just refreshing usually.
    // But LoadLikedSongs usually implies initial load or full refresh.
    emit(state.copyWith(status: LikedSongsStatus.loading));
    try {
      final totalCount = await getLikedSongsCount();
      final songs = await getLikedSongs(offset: 0, limit: 20);

      emit(
        state.copyWith(
          status: LikedSongsStatus.success,
          songs: songs,
          totalCount: totalCount,
          hasReachedMax: songs.length >= totalCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LikedSongsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMoreLikedSongs(
    LoadMoreLikedSongs event,
    Emitter<LikedSongsState> emit,
  ) async {
    if (state.hasReachedMax) return;
    try {
      final songs = await getLikedSongs(offset: state.songs.length, limit: 20);

      emit(
        songs.isEmpty
            ? state.copyWith(hasReachedMax: true)
            : state.copyWith(
                status: LikedSongsStatus.success,
                songs: List.of(state.songs)..addAll(songs),
                hasReachedMax:
                    (state.songs.length + songs.length) >= state.totalCount,
              ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LikedSongsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
