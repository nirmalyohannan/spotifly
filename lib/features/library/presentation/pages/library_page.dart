import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/theme/app_colors.dart';
import 'package:spotifly/shared/data/repositories/playlist_repository_impl.dart';
import '../bloc/playlist_bloc.dart';
import 'liked_songs_page.dart';
import 'playlist_detail_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PlaylistBloc(playlistRepository: PlaylistRepositoryImpl())
            ..add(LoadPlaylists()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: 'https://i.pravatar.cc/150?img=5',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(
                        Icons.person_outline,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          title: const Text(
            'Your Library',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          ],
        ),
        body: Column(
          children: [
            // Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildPill('Playlists'),
                  const SizedBox(width: 8),
                  _buildPill('Artists'),
                  const SizedBox(width: 8),
                  _buildPill('Albums'),
                  const SizedBox(width: 8),
                  _buildPill('Podcasts & shows'),
                ],
              ),
            ),

            // Sort Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  const Icon(Icons.sort, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Recently played',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.grid_view, size: 16, color: Colors.white),
                ],
              ),
            ),

            // List
            Expanded(
              child: BlocBuilder<PlaylistBloc, PlaylistState>(
                builder: (context, state) {
                  if (state is PlaylistLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PlaylistLoaded) {
                    return ListView(
                      children: [
                        _buildListItem(
                          context,
                          title: 'Liked Songs',
                          subtitle: 'Playlist • 58 songs',
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF450AF5), Color(0xFFC4EFDA)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<PlaylistBloc>(),
                                  child: FutureBuilder(
                                    future: PlaylistRepositoryImpl()
                                        .getLikedSongs(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return LikedSongsPage(
                                          songs: snapshot.data!,
                                        );
                                      }
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildListItem(
                          context,
                          title: 'New Episodes',
                          subtitle: 'Updated 2 days ago',
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF006450),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.notifications,
                                color: Colors.greenAccent,
                                size: 20,
                              ),
                            ),
                          ),
                          onTap: () {},
                        ),
                        ...state.playlists.map(
                          (playlist) => _buildListItem(
                            context,
                            title: playlist.title,
                            subtitle: 'Playlist • ${playlist.creator}',
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: playlist.coverUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 50,
                                  height: 50,
                                  color: AppColors.surface,
                                  child: const Center(
                                    child: Icon(
                                      Icons.music_note,
                                      color: Colors.white70,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 50,
                                  height: 50,
                                  color: AppColors.surface,
                                  child: const Center(
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.white70,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PlaylistDetailPage(playlist: playlist),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    );
                  } else if (state is PlaylistError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[800]!),
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget leading,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      onTap: onTap,
    );
  }
}
