import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotifly/features/player/data/models/cached_song_metadata.dart';

class CachedSongTile extends StatelessWidget {
  final CachedSongMetadata song;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CachedSongTile({
    super.key,
    required this.song,
    required this.isSelected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Format file size
    final mb = song.fileSize / (1024 * 1024);
    final sizeStr = '${mb.toStringAsFixed(1)} MB';

    // Format date
    // 2023-10-27 10:30 -> Oct 27
    // Let's just use days ago for simplicity if no better formatter available
    final daysAgo = DateTime.now().difference(song.lastPlayedAt).inDays;
    final dateStr = daysAgo == 0 ? 'Today' : '$daysAgo days ago';

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: song.coverUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.music_note, color: Colors.white54),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.music_note, color: Colors.white54),
              ),
            ),
          ),
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
        ],
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildChip(sizeStr, Colors.blueGrey),
              const SizedBox(width: 8),
              _buildChip(dateStr, Colors.white24),
              const SizedBox(width: 8),
              // Show source if available?
            ],
          ),
        ],
      ),
      trailing: selectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (v) => onTap(),
              fillColor: MaterialStateProperty.all(Colors.green),
              checkColor: Colors.black,
              shape: const CircleBorder(),
            )
          : null,
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
      ),
    );
  }
}
