import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotifly/core/di/service_locator.dart';
import 'package:spotifly/core/theme/app_colors.dart';
import 'package:spotifly/core/utils/flight_shuttle_builder.dart';
import 'package:spotifly/features/library/domain/use_cases/get_playlist_songs.dart';
import 'package:spotifly/features/library/presentation/widgets/library_song_tile.dart';
import 'package:spotifly/shared/domain/entities/playlist.dart';
import 'package:spotifly/shared/domain/entities/song.dart';
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
  late Future<List<Song>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = getIt<GetPlaylistSongs>().call(
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
      body: FutureBuilder<List<Song>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          final songs = snapshot.data ?? [];
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
                    title: Text(widget.playlist.title),
                    background: Hero(
                      tag: widget.playlist.id,
                      flightShuttleBuilder:
                          FlightShuttleBuilders.fadeTransition,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.playlist.coverUrl,
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
                else if (songs.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('No songs in this playlist')),
                  )
                else ...[
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final song = songs[index];
                      return LibrarySongTile(
                        song: song,
                        onTap: () => context.read<PlayerBloc>().add(
                          SetPlaylistEvent(songs: songs, initialIndex: index),
                        ),
                      );
                    }, childCount: songs.length),
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
