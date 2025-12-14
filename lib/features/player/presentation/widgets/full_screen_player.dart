import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';
import 'package:spotifly/features/player/presentation/widgets/player_album_art.dart';
import 'package:spotifly/features/player/presentation/widgets/player_appbar.dart';
import 'package:spotifly/features/player/presentation/widgets/player_controls.dart';
import 'package:spotifly/features/player/presentation/widgets/player_progress_bar.dart';
import 'package:spotifly/features/player/presentation/widgets/player_progress_time_row.dart';
import 'package:spotifly/features/player/presentation/widgets/player_title_and_artist.dart';

class FullScreenPlayer extends StatelessWidget {
  final Color? backgroundColor;
  const FullScreenPlayer({super.key, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
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
                  const PlayerControls(),

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
    );
  }
}
