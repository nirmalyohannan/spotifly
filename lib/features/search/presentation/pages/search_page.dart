import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotifly/shared/presentation/widgets/section_header.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotifly/features/search/data/repositories/search_repository_impl.dart';
import 'package:spotifly/features/search/presentation/bloc/search_bloc.dart';
import 'package:spotifly/features/library/presentation/pages/playlist_detail_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(searchRepository: SearchRepositoryImpl()),
      child: const SearchView(),
    );
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isSearching = _focusNode.hasFocus || _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Artists, songs, or podcasts',
                    hintStyle: TextStyle(color: Colors.grey[700]),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () {
                              _searchController.clear();
                              context.read<SearchBloc>().add(
                                const SearchQueryChanged(''),
                              );
                              _focusNode.unfocus();
                              setState(() {
                                _isSearching = false;
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    context.read<SearchBloc>().add(SearchQueryChanged(value));
                  },
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SearchLoaded) {
                    if (state.results.songs.isEmpty &&
                        state.results.playlists.isEmpty) {
                      return const Center(child: Text('No results found'));
                    }
                    return ListView(
                      children: [
                        if (state.results.songs.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Songs',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...state.results.songs.map(
                            (song) => ListTile(
                              leading: Image.network(
                                song.coverUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey,
                                      child: const Icon(Icons.music_note),
                                    ),
                              ),
                              title: Text(song.title),
                              subtitle: Text(song.artist),
                              onTap: () {
                                // Play song
                              },
                            ),
                          ),
                        ],
                        if (state.results.playlists.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Playlists',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...state.results.playlists.map(
                            (playlist) => ListTile(
                              leading: Image.network(
                                playlist.coverUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
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
                  } else if (state is SearchError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  // Default view (Categories)
                  return CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(
                        child: SectionHeader(title: 'Your top genres'),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.6,
                          children: const [
                            CategoryCard(
                              title: 'Pop',
                              color: Colors.purple,
                              imageUrl:
                                  'https://i.scdn.co/image/ab67616d0000b2739613a049320413c9d804599d',
                            ),
                            CategoryCard(
                              title: 'Indie',
                              color: Colors.green,
                              imageUrl:
                                  'https://i.scdn.co/image/ab67616d0000b2735d199c0115b2218e9b7327bb',
                            ),
                          ],
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SectionHeader(
                          title: 'Popular podcast categories',
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.6,
                          children: const [
                            CategoryCard(
                              title: 'News &\nPolitics',
                              color: Colors.blue,
                              imageUrl: '',
                            ),
                            CategoryCard(
                              title: 'Comedy',
                              color: Colors.orange,
                              imageUrl: '',
                            ),
                          ],
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SectionHeader(title: 'Browse all'),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.6,
                          children: const [
                            CategoryCard(
                              title: '2021 Wrapped',
                              color: Color(0xFF8D67AB),
                              imageUrl: '',
                            ),
                            CategoryCard(
                              title: 'Podcasts',
                              color: Color(0xFF27856A),
                              imageUrl: '',
                            ),
                            CategoryCard(
                              title: 'Made for you',
                              color: Color(0xFF1E3264),
                              imageUrl: '',
                            ),
                            CategoryCard(
                              title: 'Charts',
                              color: Color(0xFF8D67AB),
                              imageUrl: '',
                            ),
                            CategoryCard(
                              title: 'New Releases',
                              color: Color(0xFFE8115B),
                              imageUrl: '',
                            ),
                            CategoryCard(
                              title: 'Discover',
                              color: Color(0xFF8C1932),
                              imageUrl: '',
                            ),
                          ],
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final String imageUrl;

  const CategoryCard({
    super.key,
    required this.title,
    required this.color,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (imageUrl.isNotEmpty)
            Positioned(
              right: -15,
              bottom: 0,
              child: Transform.rotate(
                angle: 0.4,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (imageUrl.isNotEmpty)
            Positioned(
              right: -15,
              bottom: 0,
              child: Transform.rotate(
                angle: 0.4,
                child: ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.black26,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.black26,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
