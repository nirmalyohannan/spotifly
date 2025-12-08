import 'package:equatable/equatable.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

enum LikedSongsStatus { initial, loading, success, failure }

class LikedSongsState extends Equatable {
  final LikedSongsStatus status;
  // Use mixed list: real Songs and nulls for placeholders
  final List<Song?> songs;
  final bool hasReachedMax;
  final int totalCount;
  final String errorMessage;
  final bool isLoadingBackground;

  const LikedSongsState({
    this.status = LikedSongsStatus.initial,
    this.songs = const <Song?>[],
    this.hasReachedMax = false,
    this.totalCount = 0,
    this.errorMessage = '',
    this.isLoadingBackground = false,
  });

  LikedSongsState copyWith({
    LikedSongsStatus? status,
    List<Song?>? songs,
    bool? hasReachedMax,
    int? totalCount,
    String? errorMessage,
    bool? isLoadingBackground,
  }) {
    return LikedSongsState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingBackground: isLoadingBackground ?? this.isLoadingBackground,
    );
  }

  @override
  List<Object?> get props => [
    status,
    songs,
    hasReachedMax,
    totalCount,
    errorMessage,
    isLoadingBackground,
  ];
}
