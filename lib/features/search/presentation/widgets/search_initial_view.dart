import 'package:flutter/material.dart';
import 'package:spotifly/features/search/presentation/widgets/category_card.dart';
import 'package:spotifly/shared/presentation/widgets/section_header.dart';

class SearchInitialView extends StatelessWidget {
  const SearchInitialView({super.key});

  @override
  Widget build(BuildContext context) {
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
              CategoryCard(title: 'Comedy', color: Colors.orange, imageUrl: ''),
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
    );
  }
}
