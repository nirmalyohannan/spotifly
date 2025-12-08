import 'package:equatable/equatable.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

enum LikedSongsStatus { initial, loading, success, failure }

class LikedSongsState extends Equatable {
  final LikedSongsStatus status;
  final List<Song> songs;
  final bool hasReachedMax;
  final int totalCount;
  final String errorMessage;

  const LikedSongsState({
    this.status = LikedSongsStatus.initial,
    this.songs = const <Song>[],
    this.hasReachedMax = false,
    this.totalCount = 0,
    this.errorMessage = '',
  });

  LikedSongsState copyWith({
    LikedSongsStatus? status,
    List<Song>? songs,
    bool? hasReachedMax,
    int? totalCount,
    String? errorMessage,
  }) {
    return LikedSongsState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
    status,
    songs,
    hasReachedMax,
    totalCount,
    errorMessage,
  ];
}
