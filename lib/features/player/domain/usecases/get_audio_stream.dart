import '../repositories/player_repository.dart';

class GetAudioStream {
  final PlayerRepository repository;

  GetAudioStream(this.repository);

  Future<String> call(String songName, String artistName) async {
    return await repository.getAudioStreamUrl(songName, artistName);
  }
}
