import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/core/theme/app_colors.dart';
import 'package:spotifly/features/home/data/repositories/home_repository_impl.dart';
import 'package:spotifly/features/home/presentation/bloc/home_bloc.dart';
import 'package:spotifly/features/library/presentation/pages/playlist_detail_page.dart';
import 'package:spotifly/shared/presentation/widgets/cards/music_card.dart';
import 'package:spotifly/shared/presentation/widgets/horizontal_card_list.dart';
import 'package:spotifly/shared/presentation/widgets/section_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(homeRepository: HomeRepositoryImpl())..add(LoadHomeData()),
      child: Scaffold(
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
                  title: const Text('Good evening'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading) {
                        return const SizedBox(
                          height: 400,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (state is HomeLoaded) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recently Played Section
                            if (state.recentlyPlayed.isNotEmpty) ...[
                              const SectionHeader(title: 'Recently played'),
                              HorizontalCardList(
                                items: state.recentlyPlayed,
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
                            ],

                            // Featured Playlists
                            if (state.featuredPlaylists.isNotEmpty) ...[
                              const SectionHeader(title: 'Featured Playlists'),
                              HorizontalCardList(
                                items: state.featuredPlaylists,
                                height: 200,
                                itemBuilder: (context, playlist) {
                                  return MusicCard(
                                    title: playlist.title,
                                    subtitle: playlist.creator,
                                    imageUrl: playlist.coverUrl,
                                    size: 150,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PlaylistDetailPage(
                                                playlist: playlist,
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                            ],

                            // New Releases
                            if (state.newReleases.isNotEmpty) ...[
                              const SectionHeader(title: 'New Releases'),
                              HorizontalCardList(
                                items: state.newReleases,
                                height: 200,
                                itemBuilder: (context, playlist) {
                                  return MusicCard(
                                    title: playlist.title,
                                    subtitle: playlist.creator,
                                    imageUrl: playlist.coverUrl,
                                    size: 150,
                                    onTap: () {
                                      // New releases are albums, but mapped to Playlist entity.
                                      // We can treat them as playlists for detail view or create AlbumDetailPage
                                      // For now, reusing PlaylistDetailPage might work if we fetch album tracks
                                      // But PlaylistRepository.getPlaylistById expects playlist ID.
                                      // Album ID != Playlist ID.
                                      // So we might need to handle this.
                                      // For now, just open it.
                                    },
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 100),
                          ],
                        );
                      } else if (state is HomeError) {
                        return SizedBox(
                          height: 400,
                          child: Center(child: Text('Error: ${state.message}')),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
