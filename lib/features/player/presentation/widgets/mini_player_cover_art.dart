import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class MiniPlayerCoverArt extends StatelessWidget {
  const MiniPlayerCoverArt({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        bottomLeft: Radius.circular(4),
      ),
      child: CachedNetworkImage(
        imageUrl: song.coverUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 60,
          height: 60,
          color: const Color(0xFF282828),
          child: const Center(
            child: Icon(Icons.music_note, color: Colors.white70, size: 20),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 60,
          height: 60,
          color: const Color(0xFF282828),
          child: const Center(
            child: Icon(Icons.error, color: Colors.white70, size: 18),
          ),
        ),
      ),
    );
  }
}
