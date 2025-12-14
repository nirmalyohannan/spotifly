import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../shared/domain/entities/playlist.dart';
import '../../../../../shared/domain/repositories/playlist_repository.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final PlaylistRepository playlistRepository;

  PlaylistBloc({required this.playlistRepository}) : super(PlaylistInitial()) {
    on<LoadPlaylists>(_onLoadPlaylists);
  }

  Future<void> _onLoadPlaylists(
    LoadPlaylists event,
    Emitter<PlaylistState> emit,
  ) async {
    try {
      // 1. Load from cache immediately
      final userProfileImage = await playlistRepository.getUserProfileImage();
      final likedSongsCount = await playlistRepository.getLikedSongsCount();

      //This stream emits both data from cache and remote refreshing playlists
      await emit.forEach(
        playlistRepository.loadPlaylistsWithSync(),
        onData: (playlists) {
          return PlaylistLoaded(
            playlists,
            userProfileImage: userProfileImage,
            likedSongsCount: likedSongsCount,
            isLoading: true, // Show loading while we fetch fresh
          );
        },

        onError: (error, stackTrace) {
          if (state is PlaylistLoaded) {
            return (state as PlaylistLoaded).copyWith(isLoading: false);
          }
          return PlaylistError(error.toString());
        },
      );
      //Turn off loading when we have data
      if (state is PlaylistLoaded) {
        emit((state as PlaylistLoaded).copyWith(isLoading: false));
      }
    } catch (e) {
      // If we have cached data, we might want to keep showing it but with an error message?
      // Or just state.
      if (state is PlaylistLoaded) {
        // If we are already showing data, maybe just turn off loading?
        final currentState = state as PlaylistLoaded;
        emit(currentState.copyWith(isLoading: false));
        // We could emit a side-effect or separate error stream, but for now just stop loading.
      } else {
        emit(PlaylistError(e.toString()));
      }
    }
  }
}
