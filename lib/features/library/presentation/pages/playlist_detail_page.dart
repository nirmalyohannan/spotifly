import 'package:flutter/material.dart';
import '../../../../shared/domain/entities/playlist.dart';

class PlaylistDetailPage extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(playlist.title),
              background: Image.network(
                playlist.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
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
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final song = playlist.songs[index];
              return ListTile(
                leading: Image.network(
                  song.coverUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
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
                  // Play song
                },
              );
            }, childCount: playlist.songs.length),
          ),
        ],
      ),
    );
  }
}
