import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';
import 'package:spotifly/features/player/presentation/widgets/player_album_art.dart';
import 'package:spotifly/features/player/presentation/widgets/player_appbar.dart';
import 'package:spotifly/features/player/presentation/widgets/player_play_button.dart';
import 'package:spotifly/features/player/presentation/widgets/player_progress_bar.dart';
import 'package:spotifly/features/player/presentation/widgets/player_progress_time_row.dart';
import 'package:spotifly/features/player/presentation/widgets/player_title_and_artist.dart';

class FullScreenPlayer extends StatelessWidget {
  final Color? backgroundColor;
  const FullScreenPlayer({super.key, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayerState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) {
        if (state.message != null) {
          _showSnackBar(context, state);
        }
      },
      child: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          final song = state.currentSong;

          if (song == null) return const SizedBox.shrink();

          return Scaffold(
            backgroundColor:
                backgroundColor ??
                const Color(0xFF8B0000), // Deep Red from screenshot
            appBar: PlayerAppbar(song: song),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Spacer(),
                    // Album Art
                    PlayerAlbumArt(song: song),
                    const Spacer(),

                    // Title and Artist
                    PlayerTitleAndArtist(song: song, isLiked: state.isLiked),

                    const SizedBox(height: 24),

                    // Progress Bar
                    const PlayerProgressBar(),
                    PlayerProgressInTimeRow(
                      position: state.position,
                      duration: state.duration,
                    ),

                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shuffle),
                          color: Colors.green,
                          onPressed: () {},
                        ), // Shuffle on
                        IconButton(
                          icon: const Icon(Icons.skip_previous, size: 36),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                        PlayerPlayButton(
                          isPlaying: state.isPlaying,
                          isInitialBuffer: state.isInitialBuffer,
                        ),

                        IconButton(
                          icon: const Icon(Icons.skip_next, size: 36),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.repeat),
                          color: Colors.green,
                          onPressed: () {},
                        ), // Repeat one
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Lyrics / Share
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.speaker_group_outlined),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, PlayerState state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            if (state.currentSong != null)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: state.currentSong!.coverUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                state.message!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Change',
          textColor: Colors.green,
          onPressed: () {},
        ),
        backgroundColor: const Color(0xFF282828),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
