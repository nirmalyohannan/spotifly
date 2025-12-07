import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';

class PlayerPlayButton extends StatelessWidget {
  final bool isPlaying;
  final bool isInitialBuffer;
  const PlayerPlayButton({
    super.key,
    required this.isPlaying,
    required this.isInitialBuffer,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: Builder(
        builder: (context) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: isInitialBuffer
                ? const CircularProgressIndicator()
                : Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      color: Colors.black,
                      iconSize: 32,
                      onPressed: () =>
                          context.read<PlayerBloc>().add(TogglePlayEvent()),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
