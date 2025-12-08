part of 'playlist_bloc.dart';

abstract class PlaylistState extends Equatable {
  const PlaylistState();

  @override
  List<Object> get props => [];
}

class PlaylistInitial extends PlaylistState {}

class PlaylistLoading extends PlaylistState {}

class PlaylistLoaded extends PlaylistState {
  final List<Playlist> playlists;
  final String? userProfileImage;
  final int likedSongsCount;

  const PlaylistLoaded(
    this.playlists, {
    this.userProfileImage,
    this.likedSongsCount = 0,
  });

  @override
  List<Object> get props => [
    playlists,
    userProfileImage ?? '',
    likedSongsCount,
  ];
}

class PlaylistError extends PlaylistState {
  final String message;

  const PlaylistError(this.message);

  @override
  List<Object> get props => [message];
}
