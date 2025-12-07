import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/theme/app_colors.dart';
import 'package:spotifly/core/utils/flight_shuttle_builder.dart';
import 'package:spotifly/features/library/presentation/bloc/playlist_bloc.dart';
import 'package:spotifly/features/library/presentation/pages/liked_songs_page.dart';
import 'package:spotifly/features/library/presentation/pages/playlist_detail_page.dart';
import 'package:spotifly/features/library/presentation/widgets/library_list_item.dart';
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
        LibraryListItem(
          title: 'Liked Songs',
          subtitle: 'Playlist • 58 songs',
          leading: _LikedSongCover(),
          onTap: () => onLikedSongsTap(context),
        ),
        LibraryListItem(
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
          (playlist) => LibraryListItem(
            title: playlist.title,
            subtitle: 'Playlist • ${playlist.creator}',
            leading: _TileCover(playlist: playlist),
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

  void onLikedSongsTap(BuildContext context) {
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
  }
}

class _LikedSongCover extends StatelessWidget {
  const _LikedSongCover();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _TileCover extends StatelessWidget {
  final Playlist playlist;

  const _TileCover({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: playlist.id,
      flightShuttleBuilder: FlightShuttleBuilders.fadeTransition,
      child: ClipRRect(
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
              child: Icon(Icons.music_note, color: Colors.white70, size: 18),
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
    );
  }
}
