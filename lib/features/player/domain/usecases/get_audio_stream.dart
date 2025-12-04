import '../repositories/player_repository.dart';

class GetAudioStream {
  final PlayerRepository repository;

  GetAudioStream(this.repository);

  Future<String> call(String videoId) async {
    return await repository.getAudioStreamUrl(videoId);
  }
}
