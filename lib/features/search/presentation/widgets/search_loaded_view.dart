import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotifly/features/library/presentation/pages/playlist_detail_page.dart';
import 'package:spotifly/features/search/domain/entities/search_results.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_bloc.dart';
import 'package:spotifly/features/player/presentation/bloc/player_event.dart';

class SearchLoadedView extends StatelessWidget {
  final SearchResults results;
  const SearchLoadedView({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (results.songs.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Songs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...results.songs.map(
            (song) => ListTile(
              leading: CachedNetworkImage(
                imageUrl: song.coverUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorWidget: (context, error, stackTrace) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey,
                  child: const Icon(Icons.music_note),
                ),
              ),
              title: Text(song.title),
              subtitle: Text(song.artist),
              onTap: () {
                context.read<PlayerBloc>().add(SetSongEvent(song));
              },
            ),
          ),
        ],
        if (results.playlists.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Playlists',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...results.playlists.map(
            (playlist) => ListTile(
              leading: CachedNetworkImage(
                imageUrl: playlist.coverUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorWidget: (context, error, stackTrace) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey,
                  child: const Icon(Icons.music_note),
                ),
              ),
              title: Text(playlist.title),
              subtitle: Text('Playlist • ${playlist.creator}'),
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
        ],
      ],
    );
  }
}
