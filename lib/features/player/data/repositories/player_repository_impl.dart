import 'package:spotifly/features/player/data/datasources/audio_remote_data_source.dart';

import '../../domain/repositories/player_repository.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final AudioRemoteDataSource dataSource;

  PlayerRepositoryImpl(this.dataSource);

  @override
  Future<String> getAudioStreamUrl(String videoId) async {
    return await dataSource.getAudioStreamUrl(videoId);
  }
}
