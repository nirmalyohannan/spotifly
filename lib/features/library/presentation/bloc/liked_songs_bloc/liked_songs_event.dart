import 'package:equatable/equatable.dart';

abstract class LikedSongsEvent extends Equatable {
  const LikedSongsEvent();

  @override
  List<Object> get props => [];
}

class LoadLikedSongs extends LikedSongsEvent {}

class LikedSongsCountUpdated extends LikedSongsEvent {
  final int count;

  const LikedSongsCountUpdated(this.count);

  @override
  List<Object> get props => [count];
}
