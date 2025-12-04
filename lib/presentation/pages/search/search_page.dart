import 'package:flutter/material.dart';
import 'package:spotifly/presentation/widgets/section_header.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              backgroundColor: Colors.transparent,
              floating: true,
              title: Text(
                'Search',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.camera_alt_outlined),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black),
                      const SizedBox(width: 12),
                      Text(
                        'Artists, songs, or podcasts',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

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
              child: SectionHeader(title: 'Popular podcast categories'),
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

            const SliverToBoxAdapter(child: SectionHeader(title: 'Browse all')),
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
                angle: 0.4, // ~25 degrees
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
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
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
