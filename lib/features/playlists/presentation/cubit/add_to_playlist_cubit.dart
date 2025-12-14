import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/shared/domain/entities/song.dart';
import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';
import 'package:spotifly/features/settings/domain/usecases/get_user_profile.dart';
import 'add_to_playlist_state.dart';

class AddToPlaylistCubit extends Cubit<AddToPlaylistState> {
  final PlaylistRepository _playlistRepository;
  final GetUserProfile _getUserProfile;
  final Song _song;

  AddToPlaylistCubit({
    required PlaylistRepository playlistRepository,
    required GetUserProfile getUserProfile,
    required Song song,
  }) : _playlistRepository = playlistRepository,
       _getUserProfile = getUserProfile,
       _song = song,
       super(AddToPlaylistLoading()) {
    _loadPlaylists();
  }

  // Initial load of playlists and checking membership
  Future<void> _loadPlaylists() async {
    try {
      emit(AddToPlaylistLoading());

      //Fetch the playlists, without caching the songs
      final playlistStream = _playlistRepository.loadPlaylistsWithSync(
        skipCachingPlaylistSongs: true,
      );
      //First element will be cached playlists
      final allPlaylists = await playlistStream.first;

      // Get current user ID
      final userProfile = await _getUserProfile();
      final userId = userProfile.id;

      // Filter playlists by owner
      final playlists = allPlaylists
          .where((p) => p.owner?.id == userId)
          .toList();

      final Map<String, bool> membership = {};

      // Check membership for each playlist
      // This might be expensive if many playlists, but we rely on local cache mostly
      for (final playlist in playlists) {
        // This function getPlaylistSongs checks local cache first
        final songs = await _playlistRepository.getPlaylistSongs(
          playlist.id,
          playlist.snapshotId,
        );
        membership[playlist.id] = songs.any((s) => s.id == _song.id);
      }

      // Also check Liked Songs
      final isLiked = await _playlistRepository.isSongLiked(_song.id);
      // We'll treat Liked Songs as a special entry in UI, but keep track here if needed or just use separate UseCase.
      // For the UI uniformness, we can keep it separate or integrating.
      // The prompt asks to show "Liked Songs" in the list.
      // We can manage Liked Songs status check via existing repository method.

      emit(
        AddToPlaylistLoaded(
          playlists: playlists,
          membershipStatus: membership,
          isLiked: isLiked,
        ),
      );
    } catch (e) {
      emit(AddToPlaylistError("Failed to load playlists: $e"));
    }
  }

  Future<void> togglePlaylistSelection(String playlistId) async {
    final currentState = state;
    if (currentState is! AddToPlaylistLoaded) return;

    final currentStatus = currentState.membershipStatus[playlistId] ?? false;
    final newStatus = !currentStatus;

    // Optimistically update UI
    final newMembership = Map<String, bool>.from(currentState.membershipStatus);
    newMembership[playlistId] = newStatus;

    emit(currentState.copyWith(membershipStatus: newMembership));

    try {
      if (newStatus) {
        await _playlistRepository.addSongToPlaylist(playlistId, _song);
      } else {
        await _playlistRepository.removeSongFromPlaylist(playlistId, _song.id);
      }
      //Refresh the playlist list (snapshotId), without caching the songs
      //As the cache updation is already handled by the repository above
      _playlistRepository.loadPlaylistsWithSync(skipCachingPlaylistSongs: true);
    } catch (e) {
      // Revert on failure
      newMembership[playlistId] = currentStatus;
      emit(currentState.copyWith(membershipStatus: newMembership));
      // Optionally emit separate error/snackbar command
    }
  }

  Future<void> toggleLikedSongs() async {
    final currentState = state;
    if (currentState is! AddToPlaylistLoaded) return;

    final currentIsLiked = currentState.isLiked;
    final newIsLiked = !currentIsLiked;

    // Optimistically update UI
    emit(currentState.copyWith(isLiked: newIsLiked));

    try {
      if (newIsLiked) {
        await _playlistRepository.addSongToLiked(_song);
      } else {
        await _playlistRepository.removeSongFromLiked(_song.id);
      }
    } catch (e) {
      // Revert on failure
      emit(currentState.copyWith(isLiked: currentIsLiked));
      // Optionally emit separate error/snackbar command
    }
  }

  void filterPlaylists(String query) {
    if (state is AddToPlaylistLoaded) {
      emit((state as AddToPlaylistLoaded).copyWith(searchQuery: query));
    }
  }
}
