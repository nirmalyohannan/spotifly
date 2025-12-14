import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LibrarySongTileShimmer extends StatelessWidget {
  const LibrarySongTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8);
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(borderRadius: radius, color: Colors.white),
        ),
        title: Container(
          width: 100,
          height: 16,
          decoration: BoxDecoration(borderRadius: radius, color: Colors.white),
        ),
        subtitle: Container(
          width: 60,
          height: 14,
          decoration: BoxDecoration(borderRadius: radius, color: Colors.white),
        ),
      ),
    );
  }
}
