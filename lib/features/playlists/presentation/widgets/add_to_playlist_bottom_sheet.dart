import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';
import 'package:spotifly/shared/domain/entities/song.dart';
import 'package:spotifly/core/di/service_locator.dart';
import 'package:spotifly/shared/domain/repositories/playlist_repository.dart';
import 'package:spotifly/features/playlists/presentation/cubit/add_to_playlist_cubit.dart';
import 'package:spotifly/features/playlists/presentation/cubit/add_to_playlist_state.dart';
import 'package:spotifly/features/settings/domain/usecases/get_user_profile.dart';

class AddToPlaylistBottomSheet extends StatelessWidget {
  final Song song;

  const AddToPlaylistBottomSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<PlayerBloc>().add(CheckLikedStatus(song.id));
      },
      child: BlocProvider(
        create: (context) => AddToPlaylistCubit(
          playlistRepository: getIt<PlaylistRepository>(),
          getUserProfile: getIt<GetUserProfile>(),
          song: song,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF121212),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 24),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Text(
                        'Saved in',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement New Playlist creation
                        },
                        child: const Text(
                          'New playlist',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: BlocBuilder<AddToPlaylistCubit, AddToPlaylistState>(
                    builder: (context, state) {
                      if (state is AddToPlaylistLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is AddToPlaylistError) {
                        return Center(
                          child: Text(
                            'Error: ${state.message}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (state is AddToPlaylistLoaded) {
                        final playlists = state.playlists;
                        final query = state.searchQuery?.toLowerCase() ?? '';

                        final filteredPlaylists = playlists.where((p) {
                          return p.title.toLowerCase().contains(query);
                        }).toList();

                        return Column(
                          children: [
                            // Search Bar
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF282828),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: TextField(
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        onChanged: (val) => context
                                            .read<AddToPlaylistCubit>()
                                            .filterPlaylists(val),
                                        decoration: const InputDecoration(
                                          hintText: 'Find playlist',
                                          hintStyle: TextStyle(
                                            color: Colors.grey,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: Colors.white,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                            top: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF282828),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Sort',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            Expanded(
                              child: ListView(
                                children: [
                                  // Liked Songs Item (Always present)
                                  if (query.isEmpty ||
                                      "liked songs".contains(query))
                                    _buildLikedSongsTile(context, song),

                                  // Playlist Items
                                  ...filteredPlaylists.map((playlist) {
                                    final isPresent =
                                        state.membershipStatus[playlist.id] ??
                                        false;
                                    return ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CachedNetworkImage(
                                          imageUrl: playlist.coverUrl,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: Colors.grey[800],
                                                child: const Icon(
                                                  Icons.music_note,
                                                  color: Colors.white,
                                                ),
                                              ),
                                        ),
                                      ),
                                      title: Text(
                                        playlist.title,
                                        style: TextStyle(
                                          color: isPresent
                                              ? Colors.green
                                              : Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${50} songs', // TODO: Add song count to Playlist entity or fetch it
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      trailing: isPresent
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            )
                                          : IconButton(
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<AddToPlaylistCubit>()
                                                    .togglePlaylistSelection(
                                                      playlist.id,
                                                    );
                                              },
                                            ),
                                      onTap: () {
                                        context
                                            .read<AddToPlaylistCubit>()
                                            .togglePlaylistSelection(
                                              playlist.id,
                                            );
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLikedSongsTile(BuildContext context, Song song) {
    return BlocBuilder<AddToPlaylistCubit, AddToPlaylistState>(
      builder: (context, state) {
        final bool isLiked;
        if (state is AddToPlaylistLoaded) {
          isLiked = state.isLiked;
        } else {
          isLiked = false;
        }
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF450AF5),
                  Color(0xFFA0C3D2),
                ], // Gradient similar to reference
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 20),
          ),
          title: Text(
            'Liked Songs',
            style: TextStyle(
              color: isLiked ? Colors.green : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: isLiked
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.add_circle_outline, color: Colors.grey),
          onTap: () => context.read<AddToPlaylistCubit>().toggleLikedSongs(),
        );
      },
    );
  }
}
