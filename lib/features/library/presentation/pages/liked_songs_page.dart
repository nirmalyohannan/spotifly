import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/library/presentation/widgets/liked_songs_list_item.dart';
import 'package:spotifly/features/library/presentation/widgets/liked_songs_shimmer_item.dart';
import 'package:spotifly/features/library/presentation/bloc/liked_songs_bloc/liked_songs_bloc.dart';
import 'package:spotifly/features/library/presentation/bloc/liked_songs_bloc/liked_songs_state.dart';
import 'package:spotifly/shared/domain/entities/song.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';

class LikedSongsPage extends StatefulWidget {
  const LikedSongsPage({super.key});

  @override
  State<LikedSongsPage> createState() => _LikedSongsPageState();
}

class _LikedSongsPageState extends State<LikedSongsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        controller: _scrollController,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            const SliverAppBar(
              expandedHeight: 250.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Liked Songs'),
                background: _LikedSongsHeaderBackground(),
              ),
            ),
            BlocBuilder<LikedSongsBloc, LikedSongsState>(
              builder: (context, state) {
                if ((state.status == LikedSongsStatus.initial ||
                        state.status == LikedSongsStatus.loading) &&
                    state.songs.isEmpty) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => LikedSongsShimmerItem(index: index),
                      childCount: 15,
                    ),
                  );
                }

                if (state.status == LikedSongsStatus.failure &&
                    state.songs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Error: ${state.errorMessage}')),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    // Use shimmers for items not yet in the list but within totalCount
                    if (index >= state.songs.length) {
                      return LikedSongsShimmerItem(index: index);
                    }

                    final song = state.songs[index];

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: song == null
                          ? LikedSongsShimmerItem(index: index)
                          : LikedSongsListItem(
                              song: song,
                              onTap: () {
                                // Filter out nulls to get the actual list of songs to play
                                final validSongs = state.songs
                                    .where((s) => s != null)
                                    .cast<Song>()
                                    .toList();

                                // Find the correct index in the valid list
                                final initialIndex = validSongs.indexOf(song);

                                if (initialIndex != -1) {
                                  context.read<PlayerBloc>().add(
                                    SetPlaylistEvent(
                                      songs: validSongs,
                                      initialIndex: initialIndex,
                                    ),
                                  );
                                }
                              },
                            ),
                    );
                  }, childCount: state.totalCount),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

class _LikedSongsHeaderBackground extends StatelessWidget {
  const _LikedSongsHeaderBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF450AF5), Color(0xFFC4EFDA)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.favorite, size: 80, color: Colors.white),
      ),
    );
  }
}
