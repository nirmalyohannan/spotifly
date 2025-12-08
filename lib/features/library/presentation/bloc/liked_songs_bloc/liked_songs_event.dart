import 'package:equatable/equatable.dart';

abstract class LikedSongsEvent extends Equatable {
  const LikedSongsEvent();

  @override
  List<Object> get props => [];
}

class LoadLikedSongs extends LikedSongsEvent {}

class LoadMoreLikedSongs extends LikedSongsEvent {
  final int index;

  const LoadMoreLikedSongs(this.index);

  @override
  List<Object> get props => [index];
}
