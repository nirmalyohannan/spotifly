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
  final bool isLoading;

  const PlaylistLoaded(
    this.playlists, {
    this.userProfileImage,
    this.likedSongsCount = 0,
    this.isLoading = false,
  });

  @override
  List<Object> get props => [
    playlists,
    userProfileImage ?? '',
    likedSongsCount,
    isLoading,
  ];

  PlaylistLoaded copyWith({
    List<Playlist>? playlists,
    String? userProfileImage,
    int? likedSongsCount,
    bool? isLoading,
  }) {
    return PlaylistLoaded(
      playlists ?? this.playlists,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      likedSongsCount: likedSongsCount ?? this.likedSongsCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PlaylistError extends PlaylistState {
  final String message;

  const PlaylistError(this.message);

  @override
  List<Object> get props => [message];
}
