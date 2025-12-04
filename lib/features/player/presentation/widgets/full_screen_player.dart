import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';
import 'package:spotifly/shared/domain/entities/song.dart';

class FullScreenPlayer extends StatelessWidget {
  final Color? backgroundColor;
  const FullScreenPlayer({super.key, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final song = state.currentSong;

        if (song == null) return const SizedBox.shrink();

        final progress = (state.duration > Duration.zero)
            ? state.position.inMilliseconds / state.duration.inMilliseconds
            : 0.0;

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
                  Container(
                    height: 350,
                    width: 350,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(128),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: CachedNetworkImage(
                        imageUrl: song.coverUrl,
                        width: 350,
                        height: 350,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 350,
                          height: 350,
                          color: Colors.black26,
                          child: const Center(
                            child: Icon(
                              Icons.album,
                              color: Colors.white70,
                              size: 28,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 350,
                          height: 350,
                          color: Colors.black26,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white70,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Title and Artist
                  Row(
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
                            ),
                            Text(
                              song.artist,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border, size: 30),
                        onPressed: () {},
                        color: Colors.white,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Progress Bar
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      thumbColor: Colors.white,
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                    ),
                    child: Slider(
                      value: progress,
                      onChanged: (value) {
                        final position = Duration(
                          milliseconds: (state.duration.inMilliseconds * value)
                              .round(),
                        );
                        context.read<PlayerBloc>().add(SeekEvent(position));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.position.toString().substring(2, 7),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          (state.duration - state.position)
                              .toString()
                              .substring(2, 7),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: IconButton(
                          icon: Icon(
                            state.isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          color: Colors.black,
                          iconSize: 32,
                          onPressed: () =>
                              context.read<PlayerBloc>().add(TogglePlayEvent()),
                        ),
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
    );
  }
}

class PlayerAppbar extends StatelessWidget implements PreferredSizeWidget {
  const PlayerAppbar({super.key, required this.song});

  final Song? song;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(),
      ),
      leading: IconButton(
        icon: const Icon(Icons.keyboard_arrow_down),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        song?.album ?? '',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
    );
  }
}
