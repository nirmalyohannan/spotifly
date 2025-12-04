import 'package:spotifly/core/youtube_user_agent.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeAudioSource {
  // @override
  Future<String> getAudioStreamUrl(String videoId) async {
    var manifest = await YoutubeExplode().videos.streamsClient.getManifest(
      videoId,
      // The User Agent used here Must match the one used in the AudioPlayer/ File Downloader
      ytClients: [YoutubeUserAgent.ytClient],
    );

    var audioOnlyStream = manifest.audioOnly.withHighestBitrate();

    return audioOnlyStream.url.toString();
  }
}
