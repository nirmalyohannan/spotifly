import 'package:equatable/equatable.dart';
import '../../../../../shared/domain/entities/playlist.dart';

abstract class AddToPlaylistState extends Equatable {
  const AddToPlaylistState();

  @override
  List<Object?> get props => [];
}

class AddToPlaylistLoading extends AddToPlaylistState {}

class AddToPlaylistLoaded extends AddToPlaylistState {
  final List<Playlist> playlists;
  // Map of playlist IDs to boolean indicating if the song is in that playlist
  final Map<String, bool> membershipStatus;
  final String? searchQuery;
  final bool isLiked;

  const AddToPlaylistLoaded({
    required this.playlists,
    required this.membershipStatus,
    this.searchQuery,
    required this.isLiked,
  });

  AddToPlaylistLoaded copyWith({
    List<Playlist>? playlists,
    Map<String, bool>? membershipStatus,
    String? searchQuery,
    bool? isLiked,
  }) {
    return AddToPlaylistLoaded(
      playlists: playlists ?? this.playlists,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [
    playlists,
    membershipStatus,
    searchQuery,
    isLiked,
  ];
}

class AddToPlaylistError extends AddToPlaylistState {
  final String message;

  const AddToPlaylistError(this.message);

  @override
  List<Object?> get props => [message];
}
