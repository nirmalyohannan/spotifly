import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';

class CachingStreamAudioSource extends StreamAudioSource {
  final Uri uri;
  final String filePath;
  final Map<String, String>? headers;
  final Function(int fileSize) onDownloadComplete;

  CachingStreamAudioSource({
    required this.uri,
    required this.filePath,
    required this.onDownloadComplete,
    this.headers,
  }) : super(tag: uri); // Use uri as tag

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final dio = Dio();
    final startByte = start ?? 0;
    final endByte = end;

    // We only cache if we start from the beginning.
    // If the player seeks (start > 0), we don't cache this session to avoid corruption/sparsity.
    final bool isCaching = startByte == 0;
    File? cacheFile;
    IOSink? fileSink;
    int downloadedBytes = 0;

    if (isCaching) {
      log('Starting cache download for $uri to $filePath');
      cacheFile = File(filePath);
      // Ensure directory exists
      if (!await cacheFile.parent.exists()) {
        await cacheFile.parent.create(recursive: true);
      }
      fileSink = cacheFile.openWrite();
    }

    try {
      final requestHeaders = headers ?? {};
      requestHeaders['range'] = 'bytes=$startByte-${endByte ?? ''}';

      final response = await dio.getUri(
        uri,
        options: Options(
          responseType: ResponseType.stream,
          headers: requestHeaders,
        ),
      );

      final streamController = StreamController<List<int>>();
      final contentLength =
          int.tryParse(response.headers.value('content-length') ?? '0') ?? 0;

      // Determine overall content length for the Content-Range/Length headers
      // If we provided a range `start-`, total is usually in Content-Range: bytes start-end/total
      int? totalLength;
      final contentRange = response.headers.value('content-range');
      if (contentRange != null) {
        final parts = contentRange.split('/');
        if (parts.length == 2 && parts[1] != '*') {
          totalLength = int.tryParse(parts[1]);
        }
      }

      // If totalLength is still null, and we started at 0, assumes content-length is total
      if (totalLength == null && startByte == 0) {
        totalLength = contentLength;
      }

      response.data.stream.listen(
        (List<int> chunk) {
          streamController.add(chunk);
          if (isCaching && fileSink != null) {
            fileSink.add(chunk);
            downloadedBytes += chunk.length;
          }
        },
        onDone: () async {
          await streamController.close();
          if (isCaching && fileSink != null) {
            await fileSink.flush();
            await fileSink.close();

            // Verify integrity (basic check: we finished stream without error)
            // Ideally we check total length if known.
            if (totalLength != null && downloadedBytes == totalLength) {
              log('Cache download complete: $downloadedBytes bytes');
              onDownloadComplete(downloadedBytes);
            } else if (totalLength == null && downloadedBytes > 0) {
              // If we didn't get total length (e.g. chunked), but finished successfully
              log(
                'Cache download complete (length unknown): $downloadedBytes bytes',
              );
              onDownloadComplete(downloadedBytes);
            } else {
              log(
                'Cache incomplete. Expected $totalLength, got $downloadedBytes. Deleting.',
              );
              await _cleanup(cacheFile);
            }
          }
        },
        onError: (e) async {
          streamController.addError(e);
          if (isCaching) {
            await _cleanup(cacheFile);
          }
        },
        cancelOnError: true,
      );

      return StreamAudioResponse(
        sourceLength: totalLength,
        contentLength: contentLength,
        offset: startByte,
        stream: streamController.stream,
        contentType: response.headers.value('content-type') ?? 'audio/mpeg',
      );
    } catch (e) {
      log("Error requesting stream: $e");
      if (isCaching) {
        await _cleanup(cacheFile);
      }
      rethrow;
    }
  }

  Future<void> _cleanup(File? file) async {
    if (file != null && await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        log("Error deleting partial cache file: $e");
      }
    }
  }
}
