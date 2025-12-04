part of 'playlist_bloc.dart';

abstract class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object> get props => [];
}

class LoadPlaylists extends PlaylistEvent {}

class LoadLikedSongs extends PlaylistEvent {}
