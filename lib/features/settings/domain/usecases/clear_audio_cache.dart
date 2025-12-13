import 'package:spotifly/features/player/domain/repositories/audio_cache_repository.dart';

class ClearAudioCache {
  final AudioCacheRepository repository;

  ClearAudioCache(this.repository);

  Future<void> call() async {
    return await repository.clearAllCache();
  }
}
