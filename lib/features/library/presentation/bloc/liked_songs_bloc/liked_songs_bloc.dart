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
    on<LoadMoreLikedSongs>(_onLoadMoreLikedSongs);
  }

  Future<void> _onLoadLikedSongs(
    LoadLikedSongs event,
    Emitter<LikedSongsState> emit,
  ) async {
    try {
      // 1. Fetch total count first to setup skeleton list
      // Show loading initially if it's the very first time (or we can just skip if we want silent update)
      if (state.status == LikedSongsStatus.initial) {
        emit(state.copyWith(status: LikedSongsStatus.loading));
      }

      final totalCount = await getLikedSongsCount();

      // Initialize sparse list with nulls
      final List<Song?> sparseSongs = List.filled(totalCount, null);

      // 2. Load cached data for the first page
      final cachedSongs = getLikedSongs.getCached();
      for (int i = 0; i < cachedSongs.length; i++) {
        sparseSongs[i] = cachedSongs[i];
      }

      emit(
        state.copyWith(
          status: LikedSongsStatus.success,
          songs: sparseSongs,
          totalCount: totalCount,
          hasReachedMax: false,
          isLoadingBackground: true,
        ),
      );

      // 3. Trigger network fetch for fresh data
      final freshSongs = await getLikedSongs(
        offset: 0,
        limit: 20,
        forceRefresh: true,
      );

      // Update cache in memory list
      final List<Song?> updatedSongs = List.from(state.songs);
      // Ensure we don't go out of bounds if totalCount changed in meantime (rare but safe)
      for (int i = 0; i < freshSongs.length; i++) {
        if (i < updatedSongs.length) {
          updatedSongs[i] = freshSongs[i];
        }
      }

      emit(
        state.copyWith(
          songs: updatedSongs,
          isLoadingBackground: false,
          // If we got fewer songs than requested, maybe we reached max?
          // But since valid index is based on totalCount, hasReachedMax is maybe redundant or
          // means "have we loaded all items".
          // Let's stick to standard logic: hasReachedMax = loadedCount == totalCount
          // But count might have changed.
          // For simplicity: checked if all items are non-null? No, too expensive.
        ),
      );
    } catch (e) {
      // If cache was shown, we just turn off loading and maybe show snackbar event?
      // For now just update status if we failed completely, or just stop loading bg
      if (state.status == LikedSongsStatus.initial ||
          state.status == LikedSongsStatus.loading) {
        emit(
          state.copyWith(
            status: LikedSongsStatus.failure,
            errorMessage: e.toString(),
            isLoadingBackground: false,
          ),
        );
      } else {
        emit(state.copyWith(isLoadingBackground: false));
      }
    }
  }

  final Set<int> _fetchingOffsets = {};

  Future<void> _onLoadMoreLikedSongs(
    LoadMoreLikedSongs event,
    Emitter<LikedSongsState> emit,
  ) async {
    // Calculate the offset page for this index (pages of 20)
    final int limit = 20;
    final int pageOffset = (event.index ~/ limit) * limit;

    // 1. Check if we are already fetching this offset
    // This avoids multiple requests for the same page (API Duplications)
    if (_fetchingOffsets.contains(pageOffset)) return;

    // 2. Check if we actually need to fetch (is it already loaded?)
    // This is optional but good optimization.
    // If the item at 'index' or 'pageOffset' is not null, maybe we don't need to fetch?
    // But sometimes we might have gaps. Let's assume visibility implies need.
    // Better check: if the *start* of the page is not null, we probably have this page.
    if (pageOffset < state.songs.length && state.songs[pageOffset] != null) {
      // Already loaded
      return;
    }

    _fetchingOffsets.add(pageOffset);

    try {
      final songs = await getLikedSongs(offset: pageOffset, limit: limit);

      if (songs.isNotEmpty) {
        final List<Song?> updatedSongs = List.from(state.songs);
        for (int i = 0; i < songs.length; i++) {
          if (pageOffset + i < updatedSongs.length) {
            updatedSongs[pageOffset + i] = songs[i];
          }
        }

        // Check if we have loaded everything we know about
        // This is a rough check because we might have gaps
        emit(
          state.copyWith(
            songs: updatedSongs,
            hasReachedMax: updatedSongs.every((s) => s != null),
          ),
        );
      }
    } catch (e) {
      // Log error
    } finally {
      _fetchingOffsets.remove(pageOffset);
    }
  }
}
