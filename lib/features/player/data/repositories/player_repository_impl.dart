import 'package:spotifly/features/player/data/datasources/youtube_remote_data_source.dart';

import '../../domain/repositories/player_repository.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final YoutubeRemoteDataSource dataSource;

  PlayerRepositoryImpl(this.dataSource);

  @override
  Future<String> getAudioStreamUrl(String songName, String artistName) async {
    return await dataSource.getAudioStreamUrl(songName, artistName);
  }
}
