import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/theme/app_colors.dart';
import 'package:spotifly/features/library/presentation/bloc/playlist_bloc.dart';
import 'package:spotifly/features/library/presentation/pages/liked_songs_page.dart';
import 'package:spotifly/features/library/presentation/pages/playlist_detail_page.dart';
import 'package:spotifly/shared/data/repositories/playlist_repository_impl.dart';
import 'package:spotifly/shared/domain/entities/playlist.dart';

class LibraryListView extends StatelessWidget {
  final List<Playlist> playlists;

  const LibraryListView({super.key, required this.playlists});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
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
              child: Icon(Icons.favorite, color: Colors.white, size: 20),
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
        ...playlists.map(
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
                    child: Icon(Icons.error, color: Colors.white70, size: 18),
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
          ),
        ),
      ],
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
