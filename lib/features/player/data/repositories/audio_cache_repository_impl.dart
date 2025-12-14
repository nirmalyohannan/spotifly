import 'dart:io';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotifly/core/utils/logger.dart';
import 'package:spotifly/features/player/data/models/cached_song_metadata.dart';
import 'package:spotifly/features/player/domain/repositories/audio_cache_repository.dart';

class AudioCacheRepositoryImpl implements AudioCacheRepository {
  static const String boxName = 'cached_songs';

  // We assume the box is opened elsewhere (e.g. main.dart) or we open it lazily.
  // For safety, let's open lazily.
  Future<Box<CachedSongMetadata>> _getBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<CachedSongMetadata>(boxName);
    }
    return Hive.box<CachedSongMetadata>(boxName);
  }

  @override
  Future<CachedSongMetadata?> getCachedSong(String songId) async {
    try {
      final box = await _getBox();
      final metadata = box.get(songId);

      if (metadata != null) {
        final file = File(metadata.filePath);
        if (await file.exists()) {
          // Update lastPlayedAt? Maybe do that in service layer or here.
          // Let's simpler keep it as retrieval.
          return metadata;
        } else {
          // Cache entry exists but file is gone. Cleanup.
          await box.delete(songId);
          return null;
        }
      }
      return null;
    } catch (e) {
      Logger.e('AudioCacheRepositoryImpl: GetCachedSong(): Error : $e');
      return null;
    }
  }

  @override
  Future<void> saveCachedSong(CachedSongMetadata metadata) async {
    try {
      final box = await _getBox();
      await box.put(metadata.id, metadata);
      Logger.s(
        'AudioCacheRepositoryImpl: SaveCachedSong() saved: ${metadata.title}',
      );
    } catch (e) {
      Logger.e('AudioCacheRepositoryImpl: SaveCachedSong() Error : $e');
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      final box = await _getBox();
      await box.clear();

      final docsDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${docsDir.path}/audioCache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      Logger.s('AudioCacheRepositoryImpl: ClearAllCache() cleared all cache');
    } catch (e) {
      Logger.e('AudioCacheRepositoryImpl: ClearAllCache() Error : $e');
    }
  }

  @override
  Future<List<CachedSongMetadata>> getAllCachedSongs() async {
    final box = await _getBox();
    return box.values.toList();
  }
}
