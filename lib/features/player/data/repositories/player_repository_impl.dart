import 'package:spotifly/features/player/data/datasources/youtube_audio_source.dart';

import '../../domain/repositories/player_repository.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final YoutubeAudioSource dataSource;

  PlayerRepositoryImpl(this.dataSource);

  @override
  Future<String> getAudioStreamUrl(String videoId) async {
    return await dataSource.getAudioStreamUrl(videoId);
  }
}
