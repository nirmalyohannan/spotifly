import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../data_sources/mock_data.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  @override
  Future<List<Song>> getLikedSongs() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    // For now, let's assume the first 5 songs are "liked"
    return MockData.songs.take(5).toList();
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return MockData.playlists.firstWhere((playlist) => playlist.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.playlists;
  }
}
