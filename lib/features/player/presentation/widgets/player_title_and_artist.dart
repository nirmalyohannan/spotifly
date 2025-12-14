import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/features/playlists/presentation/widgets/add_to_playlist_bottom_sheet.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class PlayerTitleAndArtist extends StatelessWidget {
  const PlayerTitleAndArtist({
    super.key,
    required this.song,
    required this.isLiked,
  });

  final Song song;
  final bool isLiked;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                song.artist,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            size: 30,
          ),
          onPressed: () {
            if (isLiked) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddToPlaylistBottomSheet(song: song),
              );
            } else {
              context.read<PlayerBloc>().add(ToggleLikeStatus());
            }
          },
          color: isLiked ? Colors.green : Colors.white,
        ),
      ],
    );
  }
}
