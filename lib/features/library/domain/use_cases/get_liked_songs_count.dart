import '../../../../shared/domain/repositories/playlist_repository.dart';

class GetLikedSongsCount {
  final PlaylistRepository repository;

  GetLikedSongsCount(this.repository);

  Future<int> call() async {
    return await repository.getLikedSongsCount();
  }
}
