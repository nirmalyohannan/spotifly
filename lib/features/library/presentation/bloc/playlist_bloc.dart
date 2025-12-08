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
    emit(PlaylistLoading());
    try {
      final playlists = await playlistRepository.getPlaylists();
      final userProfileImage = await playlistRepository.getUserProfileImage();
      final likedSongsCount = await playlistRepository.getLikedSongsCount();
      emit(
        PlaylistLoaded(
          playlists,
          userProfileImage: userProfileImage,
          likedSongsCount: likedSongsCount,
        ),
      );
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }
}
