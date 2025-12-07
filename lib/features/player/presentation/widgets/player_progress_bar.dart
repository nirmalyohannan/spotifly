import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';

class PlayerProgressBar extends StatelessWidget {
  const PlayerProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
        thumbColor: Colors.white,
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      ),
      child: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          final progress = (state.duration > Duration.zero)
              ? (state.position.inMilliseconds / state.duration.inMilliseconds)
                    .clamp(0.0, 1.0)
              : 0.0;
          return Slider(
            value: progress,
            onChanged: (value) {
              final position = Duration(
                milliseconds: (state.duration.inMilliseconds * value).round(),
              );
              context.read<PlayerBloc>().add(SeekEvent(position));
            },
          );
        },
      ),
    );
  }
}
