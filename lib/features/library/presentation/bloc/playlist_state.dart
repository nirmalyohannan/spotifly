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

  const PlaylistLoaded(this.playlists, {this.userProfileImage});

  @override
  List<Object> get props => [playlists, userProfileImage ?? ''];
}

class LikedSongsLoaded extends PlaylistState {
  final List<Song> songs;

  const LikedSongsLoaded(this.songs);

  @override
  List<Object> get props => [songs];
}

class PlaylistError extends PlaylistState {
  final String message;

  const PlaylistError(this.message);

  @override
  List<Object> get props => [message];
}
