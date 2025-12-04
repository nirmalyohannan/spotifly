import 'dart:io';

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
    final AudioOnlyStreamInfo audioStreamInfo;
    if (Platform.isAndroid || Platform.isWindows || Platform.isLinux) {
      audioStreamInfo = manifest.audioOnly.withHighestBitrate();
    } else {
      //For IOS, MacOS, Web
      //These platforms may not support .Opus format
      //So  using mp4
      audioStreamInfo = manifest.audioOnly
          .where((element) => element.container.name == 'mp4')
          .withHighestBitrate();
    }

    return audioStreamInfo.url.toString();
  }
}
