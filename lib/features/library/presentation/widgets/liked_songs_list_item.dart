import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class LikedSongsListItem extends StatelessWidget {
  const LikedSongsListItem({super.key, required this.song, this.onTap});

  final Song song;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: song.coverUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorWidget: (context, error, stackTrace) => Container(
          width: 50,
          height: 50,
          color: Colors.grey,
          child: const Icon(Icons.music_note),
        ),
      ),
      title: Text(song.title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(song.artist, style: const TextStyle(color: Colors.grey)),
      onTap: onTap,
    );
  }
}
