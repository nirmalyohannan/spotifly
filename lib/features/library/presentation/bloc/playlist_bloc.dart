import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/playlist.dart';
import '../../../../shared/domain/entities/song.dart';
import '../../../../shared/domain/repositories/playlist_repository.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final PlaylistRepository playlistRepository;

  PlaylistBloc({required this.playlistRepository}) : super(PlaylistInitial()) {
    on<LoadPlaylists>(_onLoadPlaylists);
    on<LoadLikedSongs>(_onLoadLikedSongs);
  }

  Future<void> _onLoadPlaylists(
    LoadPlaylists event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading());
    try {
      final playlists = await playlistRepository.getPlaylists();
      emit(PlaylistLoaded(playlists));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }

  Future<void> _onLoadLikedSongs(
    LoadLikedSongs event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(PlaylistLoading());
    try {
      final songs = await playlistRepository.getLikedSongs();
      emit(LikedSongsLoaded(songs));
    } catch (e) {
      emit(PlaylistError(e.toString()));
    }
  }
}
