import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';
import 'package:spotifly/features/player/presentation/widgets/player_play_button.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.shuffle),
              color: state.isShuffleMode ? Colors.green : Colors.white,
              onPressed: () {
                context.read<PlayerBloc>().add(ToggleShuffleModeEvent());
              },
            ), // Shuffle on
            IconButton(
              icon: const Icon(Icons.skip_previous, size: 36),
              color: Colors.white,
              onPressed: () {
                context.read<PlayerBloc>().add(PlayPreviousEvent());
              },
            ),
            PlayerPlayButton(
              isPlaying: state.isPlaying,
              isInitialBuffer: state.isInitialBuffer,
            ),

            IconButton(
              icon: const Icon(Icons.skip_next, size: 36),
              color: Colors.white,
              onPressed: () {
                context.read<PlayerBloc>().add(PlayNextEvent());
              },
            ),
            IconButton(
              icon: const Icon(Icons.repeat),
              color: state.isRepeatMode ? Colors.green : Colors.white,
              onPressed: () {
                context.read<PlayerBloc>().add(ToggleRepeatModeEvent());
              },
            ), // Repeat one
          ],
        );
      },
    );
  }
}
