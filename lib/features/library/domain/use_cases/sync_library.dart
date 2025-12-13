import '../../../../shared/domain/repositories/playlist_repository.dart';

class SyncLibrary {
  final PlaylistRepository repository;

  SyncLibrary(this.repository);

  Future<void> call() async {
    return repository.syncLibrary();
  }
}
