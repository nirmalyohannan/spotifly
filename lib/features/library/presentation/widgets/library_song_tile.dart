import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:spotifly/core/assets.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class LibrarySongTile extends StatelessWidget {
  const LibrarySongTile({super.key, required this.song, required this.onTap});

  final Song song;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PlayerBloc, PlayerState, bool>(
      selector: (state) {
        return state.currentSong?.id == song.id;
      },
      builder: (context, isPlaying) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: ListTile(
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
            title: Text(
              song.title,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              song.artist,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: isPlaying
                ? LottieBuilder.asset(
                    Assets.lotties.isPlaying,
                    repeat: true,
                    width: 50,
                    height: 50,
                  )
                : null,
            onTap: onTap,
          ),
        );
      },
    );
  }
}
