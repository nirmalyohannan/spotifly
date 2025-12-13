import '../../data/models/cached_song_metadata.dart';

abstract class AudioCacheRepository {
  Future<CachedSongMetadata?> getCachedSong(String songId);
  Future<void> saveCachedSong(CachedSongMetadata metadata);
  Future<void> clearAllCache();
  Future<List<CachedSongMetadata>> getAllCachedSongs();
}
