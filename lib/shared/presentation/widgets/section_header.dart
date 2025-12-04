import 'package:flutter/material.dart';
import 'package:spotifly/core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMoreTap;

  const SectionHeader({super.key, required this.title, this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onMoreTap != null)
            Icon(
              Icons
                  .bolt, // Placeholder for settings or history if needed, or just omit
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}
