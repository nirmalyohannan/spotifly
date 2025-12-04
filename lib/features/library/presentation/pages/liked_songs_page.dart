import 'package:flutter/material.dart';
import '../../../../shared/domain/entities/song.dart';

class LikedSongsPage extends StatelessWidget {
  final List<Song> songs;

  const LikedSongsPage({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Liked Songs'),
              background: Container(
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
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final song = songs[index];
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
                trailing: const Icon(Icons.favorite, color: Colors.green),
                onTap: () {
                  // Play song
                },
              );
            }, childCount: songs.length),
          ),
        ],
      ),
    );
  }
}
