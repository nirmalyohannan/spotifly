import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotifly/core/theme/app_colors.dart';

class MusicCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String imageUrl;
  final bool isCircular;
  final VoidCallback? onTap;
  final double size;

  const MusicCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.isCircular = false,
    this.onTap,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment: isCircular
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(isCircular ? size / 2 : 4),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(Icons.music_note, color: Colors.grey),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isCircular ? TextAlign.center : TextAlign.start,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: isCircular ? TextAlign.center : TextAlign.start,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
