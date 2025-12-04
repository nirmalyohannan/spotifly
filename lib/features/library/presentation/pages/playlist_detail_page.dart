import 'package:flutter/material.dart';
import 'package:spotifly/shared/data/repositories/playlist_repository_impl.dart';
import '../../../../shared/domain/entities/playlist.dart';

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  late Future<Playlist?> _playlistFuture;

  @override
  void initState() {
    super.initState();
    _playlistFuture = PlaylistRepositoryImpl().getPlaylistById(
      widget.playlist.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Playlist?>(
        future: _playlistFuture,
        builder: (context, snapshot) {
          final playlist = snapshot.data ?? widget.playlist;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return CustomScrollView(
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
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (playlist.songs.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No songs in this playlist')),
                )
              else
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
          );
        },
      ),
    );
  }
}
