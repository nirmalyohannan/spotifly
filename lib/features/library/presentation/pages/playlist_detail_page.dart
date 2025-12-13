import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:spotifly/core/assets.dart';
import 'package:spotifly/core/di/service_locator.dart';
import 'package:spotifly/core/theme/app_colors.dart';
import 'package:spotifly/core/utils/flight_shuttle_builder.dart';
import 'package:spotifly/features/library/domain/use_cases/get_playlist_by_id.dart';
import 'package:spotifly/features/player/presentation/bloc/player_state.dart';
import '../../../../shared/domain/entities/playlist.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final _scrollController = ScrollController();
  late Future<Playlist?> _playlistFuture;

  @override
  void initState() {
    super.initState();
    _playlistFuture = getIt<GetPlaylistById>().call(
      widget.playlist.id,
      widget.playlist.snapshotId,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Playlist?>(
        future: _playlistFuture,
        builder: (context, snapshot) {
          final playlist = snapshot.data ?? widget.playlist;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return Scrollbar(
            controller: _scrollController,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: 300.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(playlist.title),
                    background: Hero(
                      tag: playlist.id,
                      flightShuttleBuilder:
                          FlightShuttleBuilders.fadeTransition,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: playlist.coverUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey,
                                  child: const Center(
                                    child: Icon(
                                      Icons.music_note,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.background,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (playlist.songs.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('No songs in this playlist')),
                  )
                else ...[
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final song = playlist.songs[index];
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
                              trailing: isPlaying
                                  ? LottieBuilder.asset(
                                      Assets.lotties.isPlaying,
                                      repeat: true,
                                      width: 50,
                                      height: 50,
                                    )
                                  : null,
                              onTap: () {
                                context.read<PlayerBloc>().add(
                                  SetPlaylistEvent(
                                    songs: playlist.songs,
                                    initialIndex: index,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }, childCount: playlist.songs.length),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
