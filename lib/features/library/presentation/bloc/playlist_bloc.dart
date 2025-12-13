import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/playlist.dart';
import '../../../../shared/domain/repositories/playlist_repository.dart';

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
      final cachedPlaylists = await playlistRepository.getCachedPlaylists();
      final userProfileImage = await playlistRepository.getUserProfileImage();
      final likedSongsCount = await playlistRepository.getLikedSongsCount();

      if (cachedPlaylists.isNotEmpty) {
        emit(
          PlaylistLoaded(
            cachedPlaylists,
            userProfileImage: userProfileImage,
            likedSongsCount: likedSongsCount,
            isLoading: true, // Show loading while we fetch fresh
          ),
        );
      } else {
        emit(PlaylistLoading());
      }

      // 2. Refresh from remote
      final freshPlaylists = await playlistRepository.refreshPlaylists();
      // Refetch others if needed (though they might share cache logic)
      final freshLikedSongsCount = await playlistRepository
          .getLikedSongsCount();
      final freshUserProfileImage = await playlistRepository
          .getUserProfileImage();

      emit(
        PlaylistLoaded(
          freshPlaylists,
          userProfileImage: freshUserProfileImage,
          likedSongsCount: freshLikedSongsCount,
          isLoading: false,
        ),
      );
    } catch (e) {
      // If we have cached data, we might want to keep showing it but with an error message?
      // Or just state.
      if (state is PlaylistLoaded) {
        // If we are already showing data, maybe just turn off loading?
        final currentState = state as PlaylistLoaded;
        emit(
          PlaylistLoaded(
            currentState.playlists,
            userProfileImage: currentState.userProfileImage,
            likedSongsCount: currentState.likedSongsCount,
            isLoading: false,
          ),
        );
        // We could emit a side-effect or separate error stream, but for now just stop loading.
      } else {
        emit(PlaylistError(e.toString()));
      }
    }
  }
}
