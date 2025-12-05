import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/theme/app_colors.dart';
import 'package:spotifly/features/library/presentation/bloc/playlist_bloc.dart';
import 'package:spotifly/features/library/presentation/pages/liked_songs_page.dart';
import 'package:spotifly/features/library/presentation/pages/playlist_detail_page.dart';
import 'package:spotifly/shared/data/repositories/playlist_repository_impl.dart';
import 'package:spotifly/shared/domain/entities/playlist.dart';

class LibraryGridView extends StatelessWidget {
  final List<Playlist> playlists;

  const LibraryGridView({super.key, required this.playlists});

  @override
  Widget build(BuildContext context) {
    final totalItems =
        2 + playlists.length; // Liked Songs + New Episodes + Playlists

    return GridView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75, // Adjust as needed
      ),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildGridItem(
            context,
            title: 'Liked Songs',
            subtitle: 'Playlist • 58 songs',
            image: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF450AF5), Color(0xFFC4EFDA)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.favorite, color: Colors.white, size: 40),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<PlaylistBloc>(),
                    child: FutureBuilder(
                      future: PlaylistRepositoryImpl().getLikedSongs(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return LikedSongsPage(songs: snapshot.data!);
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
              );
            },
          );
        } else if (index == 1) {
          return _buildGridItem(
            context,
            title: 'New Episodes',
            subtitle: 'Updated 2 days ago',
            image: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF006450),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.notifications,
                  color: Colors.greenAccent,
                  size: 40,
                ),
              ),
            ),
            onTap: () {},
          );
        } else {
          final playlist = playlists[index - 2];
          return _buildGridItem(
            context,
            title: playlist.title,
            subtitle: 'Playlist • ${playlist.creator}',
            image: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: playlist.coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(
                      Icons.music_note,
                      color: Colors.white70,
                      size: 30,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.white70, size: 30),
                  ),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistDetailPage(playlist: playlist),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(width: double.infinity, child: image),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
