import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spotifly/features/library/presentation/bloc/liked_songs_bloc/liked_songs_bloc.dart';
import 'package:spotifly/features/library/presentation/bloc/liked_songs_bloc/liked_songs_event.dart';
import 'package:spotifly/features/library/presentation/bloc/liked_songs_bloc/liked_songs_state.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/features/player/presentation/widgets/mini_player.dart';

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
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<LikedSongsBloc>().add(LoadMoreLikedSongs());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
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
                  if (state.status == LikedSongsStatus.initial ||
                      (state.status == LikedSongsStatus.loading &&
                          state.songs.isEmpty)) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const _ShimmerListItem(),
                        childCount: 15,
                      ),
                    );
                  }

                  if (state.status == LikedSongsStatus.failure &&
                      state.songs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text('Error: ${state.errorMessage}'),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= state.songs.length) {
                          return const SizedBox(
                            height: 50,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final song = state.songs[index];
                        return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: song.coverUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) =>
                                Container(
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
                          onTap: () {
                            context.read<PlayerBloc>().add(SetSongEvent(song));
                          },
                        );
                      },
                      childCount: state.hasReachedMax
                          ? state.songs.length
                          : state.songs.length + 1,
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
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

class _ShimmerListItem extends StatelessWidget {
  const _ShimmerListItem();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: ListTile(
        leading: Container(width: 50, height: 50, color: Colors.white),
        title: Container(width: 100, height: 16, color: Colors.white),
        subtitle: Container(width: 60, height: 14, color: Colors.white),
      ),
    );
  }
}
