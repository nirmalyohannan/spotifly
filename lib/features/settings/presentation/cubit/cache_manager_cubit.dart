import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/player/data/models/cached_song_metadata.dart';
import 'package:spotifly/features/player/domain/entities/cache_source.dart';
import 'package:spotifly/features/player/domain/repositories/audio_cache_repository.dart';

// --- State ---
abstract class CacheManagerState extends Equatable {
  const CacheManagerState();

  @override
  List<Object?> get props => [];
}

class CacheManagerLoading extends CacheManagerState {}

class CacheManagerLoaded extends CacheManagerState {
  final List<CachedSongMetadata> allSongs;
  final List<CachedSongMetadata> filteredSongs;
  final Set<String> selectedIds;
  final SortOption sortOption;
  final TimeRange filterTimeRange;
  final CacheSource? filterSource;

  const CacheManagerLoaded({
    required this.allSongs,
    required this.filteredSongs,
    this.selectedIds = const {},
    this.sortOption = SortOption.dateDesc,
    this.filterTimeRange = TimeRange.all,
    this.filterSource,
  });

  CacheManagerLoaded copyWith({
    List<CachedSongMetadata>? allSongs,
    List<CachedSongMetadata>? filteredSongs,
    Set<String>? selectedIds,
    SortOption? sortOption,
    TimeRange? filterTimeRange,
    CacheSource? filterSource,
  }) {
    return CacheManagerLoaded(
      allSongs: allSongs ?? this.allSongs,
      filteredSongs: filteredSongs ?? this.filteredSongs,
      selectedIds: selectedIds ?? this.selectedIds,
      sortOption: sortOption ?? this.sortOption,
      filterTimeRange: filterTimeRange ?? this.filterTimeRange,
      filterSource: filterSource ?? this.filterSource,
    );
  }

  @override
  List<Object?> get props => [
    allSongs,
    filteredSongs,
    selectedIds,
    sortOption,
    filterTimeRange,
    filterSource,
  ];
}

class CacheManagerError extends CacheManagerState {
  final String message;

  const CacheManagerError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Cubit ---
class CacheManagerCubit extends Cubit<CacheManagerState> {
  final AudioCacheRepository _repository;

  CacheManagerCubit(this._repository) : super(CacheManagerLoading());

  Future<void> loadCachedSongs() async {
    try {
      final songs = await _repository.getAllCachedSongs();
      _emitLoaded(allSongs: songs, filtered: songs);
    } catch (e) {
      emit(CacheManagerError(e.toString()));
    }
  }

  void sortSongs(SortOption option) {
    if (state is CacheManagerLoaded) {
      final currentState = state as CacheManagerLoaded;
      final sorted = _applySortAndFilter(
        currentState.allSongs,
        option,
        currentState.filterTimeRange,
        currentState.filterSource,
      );
      emit(currentState.copyWith(sortOption: option, filteredSongs: sorted));
    }
  }

  void filterSongs({TimeRange? timeRange, CacheSource? source}) {
    if (state is CacheManagerLoaded) {
      final currentState = state as CacheManagerLoaded;
      final newTimeRange = timeRange ?? currentState.filterTimeRange;
      // Actuallly, let's make it simpler: update one or both.
      final effectiveSource = (source == null && timeRange != null)
          ? currentState.filterSource
          : source;

      final filtered = _applySortAndFilter(
        currentState.allSongs,
        currentState.sortOption,
        newTimeRange,
        effectiveSource,
      );
      emit(
        currentState.copyWith(
          filterTimeRange: newTimeRange,
          filterSource: effectiveSource,
          filteredSongs: filtered,
          selectedIds:
              {}, // Clear selection on filter change? Maybe keep it. Let's keep it but filter logic handles display.
        ),
      );
    }
  }

  void toggleSelection(String id) {
    if (state is CacheManagerLoaded) {
      final currentState = state as CacheManagerLoaded;
      final newSelected = Set<String>.from(currentState.selectedIds);
      if (newSelected.contains(id)) {
        newSelected.remove(id);
      } else {
        newSelected.add(id);
      }
      emit(currentState.copyWith(selectedIds: newSelected));
    }
  }

  void selectAll() {
    if (state is CacheManagerLoaded) {
      final currentState = state as CacheManagerLoaded;
      final allIds = currentState.filteredSongs.map((e) => e.id).toSet();
      emit(currentState.copyWith(selectedIds: allIds));
    }
  }

  void clearSelection() {
    if (state is CacheManagerLoaded) {
      final currentState = state as CacheManagerLoaded;
      emit(currentState.copyWith(selectedIds: {}));
    }
  }

  Future<void> deleteSelected() async {
    if (state is CacheManagerLoaded) {
      final currentState = state as CacheManagerLoaded;
      if (currentState.selectedIds.isEmpty) return;

      try {
        await _repository.deleteCachedSongs(currentState.selectedIds.toList());
        await loadCachedSongs(); // Reload to refresh list
      } catch (e) {
        emit(CacheManagerError("Failed to delete songs: $e"));
      }
    }
  }

  Future<void> deleteAll() async {
    try {
      await _repository.clearAllCache();
      await loadCachedSongs();
    } catch (e) {
      emit(CacheManagerError("Failed to clear cache: $e"));
    }
  }

  // --- Helper Methods ---

  List<CachedSongMetadata> _applySortAndFilter(
    List<CachedSongMetadata> songs,
    SortOption sortOption,
    TimeRange timeRange,
    CacheSource? source,
  ) {
    var result = List<CachedSongMetadata>.from(songs);

    // Filter by TimeRange
    final now = DateTime.now();
    if (timeRange != TimeRange.all) {
      final days = _getDaysFromRange(timeRange);
      final cutoff = now.subtract(Duration(days: days));
      result = result.where((e) => e.lastPlayedAt.isAfter(cutoff)).toList();
    }

    // Filter by Source
    if (source != null) {
      result = result.where((e) => e.source == source).toList();
    }

    // Sort
    result.sort((a, b) {
      switch (sortOption) {
        case SortOption.dateDesc:
          return b.lastPlayedAt.compareTo(a.lastPlayedAt);
        case SortOption.dateAsc:
          return a.lastPlayedAt.compareTo(b.lastPlayedAt);
        case SortOption.sizeDesc:
          return b.fileSize.compareTo(a.fileSize);
        case SortOption.sizeAsc:
          return a.fileSize.compareTo(b.fileSize);
        case SortOption.titleAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SortOption.titleDesc:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        case SortOption.durationDesc:
          return b.durationMs.compareTo(a.durationMs);
        case SortOption.durationAsc:
          return a.durationMs.compareTo(b.durationMs);
      }
    });

    return result;
  }

  int _getDaysFromRange(TimeRange range) {
    switch (range) {
      case TimeRange.last30Days:
        return 30;
      case TimeRange.last60Days:
        return 60;
      case TimeRange.last90Days:
        return 90;
      case TimeRange.all:
        return 36500; // 100 years
    }
  }

  void _emitLoaded({
    required List<CachedSongMetadata> allSongs,
    required List<CachedSongMetadata> filtered,
  }) {
    emit(CacheManagerLoaded(allSongs: allSongs, filteredSongs: filtered));
  }
}

// --- Enums ---
enum SortOption {
  dateDesc,
  dateAsc,
  sizeDesc,
  sizeAsc,
  titleAsc,
  titleDesc,
  durationDesc,
  durationAsc,
}

enum TimeRange { all, last30Days, last60Days, last90Days }
