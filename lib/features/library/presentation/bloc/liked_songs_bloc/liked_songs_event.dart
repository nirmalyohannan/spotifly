import 'package:equatable/equatable.dart';

abstract class LikedSongsEvent extends Equatable {
  const LikedSongsEvent();

  @override
  List<Object> get props => [];
}

class LoadLikedSongs extends LikedSongsEvent {}

class LoadMoreLikedSongs extends LikedSongsEvent {}
