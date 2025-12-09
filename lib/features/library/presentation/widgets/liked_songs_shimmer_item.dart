import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spotifly/features/library/presentation/bloc/liked_songs_bloc/liked_songs_bloc.dart';
import 'package:spotifly/features/library/presentation/bloc/liked_songs_bloc/liked_songs_event.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LikedSongsShimmerItem extends StatelessWidget {
  final int index;
  const LikedSongsShimmerItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8);
    return VisibilityDetector(
      key: Key('shimmer-liked-song-$index'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1) {
          context.read<LikedSongsBloc>().add(LoadMoreLikedSongs(index));
        }
      },
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[600]!,
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: radius,
              color: Colors.white,
            ),
          ),
          title: Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: radius,
              color: Colors.white,
            ),
          ),
          subtitle: Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              borderRadius: radius,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
