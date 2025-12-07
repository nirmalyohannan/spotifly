import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class PlayerAlbumArt extends StatelessWidget {
  const PlayerAlbumArt({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: 350,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(128),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: CachedNetworkImage(
          imageUrl: song.coverUrl,
          width: 350,
          height: 350,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 350,
            height: 350,
            color: Colors.black26,
            child: const Center(
              child: Icon(Icons.album, color: Colors.white70, size: 28),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 350,
            height: 350,
            color: Colors.black26,
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white70, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
