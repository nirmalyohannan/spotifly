import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/theme/app_colors.dart';
import 'package:spotifly/features/library/presentation/bloc/playlist_bloc.dart';
import 'package:spotifly/features/library/presentation/pages/liked_songs_page.dart';
import 'package:spotifly/features/library/presentation/pages/playlist_detail_page.dart';
import 'package:spotifly/features/library/presentation/widgets/library_grid_item.dart';
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
          return LibraryGridItem(
            title: 'Liked Songs',
            subtitle: 'Playlist • 58 songs',
            image: _LikedSongsCover(),
            onTap: () => _onTapLikedSongs(context),
          );
        } else if (index == 1) {
          return LibraryGridItem(
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
          return LibraryGridItem(
            title: playlist.title,
            subtitle: 'Playlist • ${playlist.creator}',
            image: _PlaylistCover(playlist: playlist),
            onTap: () => _onTapPlaylist(context, playlist),
          );
        }
      },
    );
  }

  void _onTapPlaylist(BuildContext context, Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailPage(playlist: playlist),
      ),
    );
  }

  void _onTapLikedSongs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
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
  }
}

class _PlaylistCover extends StatelessWidget {
  const _PlaylistCover({required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: playlist.coverUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surface,
          child: const Center(
            child: Icon(Icons.music_note, color: Colors.white70, size: 30),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.surface,
          child: const Center(
            child: Icon(Icons.error, color: Colors.white70, size: 30),
          ),
        ),
      ),
    );
  }
}

class _LikedSongsCover extends StatelessWidget {
  const _LikedSongsCover();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
