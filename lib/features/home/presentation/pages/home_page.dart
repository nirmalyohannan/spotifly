import 'package:flutter/material.dart';
import 'package:spotifly/core/theme/app_colors.dart';
import 'package:spotifly/shared/data/data_sources/mock_data.dart';
import 'package:spotifly/shared/presentation/widgets/cards/music_card.dart';
import 'package:spotifly/shared/presentation/widgets/horizontal_card_list.dart';
import 'package:spotifly/shared/presentation/widgets/section_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF404040), // Dark grey gradient start
              AppColors.background,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                floating: true,
                title: const Text('Recently played'), // Based on screenshot
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                  IconButton(icon: const Icon(Icons.history), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recently Played Section
                    HorizontalCardList(
                      items: MockData.songs, // Using songs as recent items
                      height: 180,
                      itemBuilder: (context, song) {
                        return MusicCard(
                          title: song.title,
                          subtitle: song.artist,
                          imageUrl: song.coverUrl,
                          size: 120,
                          onTap: () {},
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Your 2021 in review Section
                    const SectionHeader(title: 'Your 2021 in review'),
                    HorizontalCardList(
                      items: MockData.playlists,
                      height: 200,
                      itemBuilder: (context, playlist) {
                        return MusicCard(
                          title: playlist.title,
                          subtitle:
                              'Your Artists Revealed', // Hardcoded for visual match
                          imageUrl: playlist.coverUrl,
                          size: 150,
                          onTap: () {},
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Editor's picks Section
                    const SectionHeader(title: "Editor's picks"),
                    HorizontalCardList(
                      items: MockData.playlists.reversed
                          .toList(), // Just shuffle for variety
                      height: 200,
                      itemBuilder: (context, playlist) {
                        return MusicCard(
                          title: playlist.title,
                          subtitle: playlist.creator,
                          imageUrl: playlist.coverUrl,
                          size: 150,
                          onTap: () {},
                        );
                      },
                    ),
                    const SizedBox(height: 100), // Bottom padding for player
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
