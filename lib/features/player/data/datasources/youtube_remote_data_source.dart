import 'package:spotifly/core/youtube_user_agent.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class YoutubeRemoteDataSource {
  Future<String> getAudioStreamUrl(String songName, String artistName);
}

class YoutubeRemoteDataSourceImpl implements YoutubeRemoteDataSource {
  final YoutubeExplode _yt;

  YoutubeRemoteDataSourceImpl(this._yt);

  @override
  Future<String> getAudioStreamUrl(String songName, String artistName) async {
    final query = '$songName $artistName official audio';
    final searchResult = await _yt.search(query);

    if (searchResult.isEmpty) {
      throw Exception('Video not found');
    }

    final video = searchResult.first;
    final manifest = await _yt.videos.streamsClient.getManifest(
      video.id,
      ytClients: [YoutubeUserAgent.ytClient],
    );
    final audioStreamInfo = manifest.audioOnly.withHighestBitrate();

    return audioStreamInfo.url.toString();
  }
}
