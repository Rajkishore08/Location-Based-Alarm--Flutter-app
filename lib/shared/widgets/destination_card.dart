import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../models/destination.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;
  final bool isSelected;
  final VoidCallback? onFavoriteTap;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
    this.isSelected = false,
    this.onFavoriteTap,
  });

  IconData _getIconData(String? name) {
    switch (name) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'train':
      case 'station':
        return Icons.train_rounded;
      case 'flight':
      case 'transit':
        return Icons.flight_takeoff_rounded;
      case 'directions_bus':
        return Icons.directions_bus_rounded;
      case 'subway':
        return Icons.subway_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderXl,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryContainer.withValues(alpha: 0.3) : AppColors.surfaceContainerHigh)
              : (isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow),
          borderRadius: AppRadius.borderXl,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryContainer
                : (isDark ? AppColors.glassBorderDark : AppColors.outlineVariant.withValues(alpha: 0.4)),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer
                    : (isDark ? AppColors.inverseSurface : AppColors.surfaceContainerHighest),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(destination.iconName ?? destination.category),
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.inversePrimary : AppColors.primary),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    destination.address,
                    style: AppTypography.bodyMd.copyWith(
                      color: isDark ? AppColors.outlineVariant : AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (destination.distanceMeters != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${(destination.distanceMeters! / 1000).toStringAsFixed(1)} km away',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onFavoriteTap != null)
              IconButton(
                onPressed: onFavoriteTap,
                icon: const Icon(Icons.bookmark_outline_rounded, color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
