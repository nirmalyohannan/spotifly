import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/utils/flight_shuttle_builder.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';
import 'package:spotifly/features/player/presentation/widgets/full_screen_player.dart';
import 'package:spotifly/features/player/presentation/widgets/mini_player_cover_art.dart';
import 'package:spotifly/features/player/presentation/widgets/mini_player_title_and_artist.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'mini_player',
      flightShuttleBuilder: flightShuttleBuilder,
      child: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          final song = state.currentSong;

          if (song == null) return const SizedBox.shrink();

          final progress = (state.duration > Duration.zero)
              ? (state.position.inMilliseconds / state.duration.inMilliseconds)
                    .clamp(0.0, 1.0)
              : 0.0;

          return GestureDetector(
            onTap: () {
              final bgColor = const Color(0xFF8B0000);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                barrierColor: bgColor,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    FullScreenPlayer(backgroundColor: bgColor),
              );
            },
            child: Container(
              height: 60, // Standard height
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF282828), // Dark grey
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        MiniPlayerCoverArt(song: song),
                        const SizedBox(width: 12),
                        Expanded(child: MiniPlayerTitleAndArtist(song: song)),
                        IconButton(
                          icon: const Icon(
                            Icons.speaker_group_outlined,
                            color: Colors.white,
                          ), // Devices
                          onPressed: () {},
                        ),
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: state.isInitialBuffer
                                ? const CircularProgressIndicator()
                                : IconButton(
                                    icon: Icon(
                                      state.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      context.read<PlayerBloc>().add(
                                        TogglePlayEvent(),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
