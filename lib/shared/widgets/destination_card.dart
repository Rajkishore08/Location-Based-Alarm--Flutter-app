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
              ? AppColors.primaryContainer.withValues(alpha: 0.25)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: AppRadius.borderXl,
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : AppColors.primaryContainer.withValues(alpha: 0.2),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.secondary.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [AppColors.primaryContainer, AppColors.secondary]
                      : [AppColors.primaryContainer.withValues(alpha: 0.15), const Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                _getIconData(destination.iconName ?? destination.category),
                color: isSelected ? Colors.white : AppColors.secondary,
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
                      color: isDark ? AppColors.onSurface : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    destination.address,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.outline,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (destination.distanceMeters != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.near_me_rounded, size: 12, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          '${(destination.distanceMeters! / 1000).toStringAsFixed(1)} km away',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onFavoriteTap != null)
              IconButton(
                onPressed: onFavoriteTap,
                icon: const Icon(Icons.bookmark_outline_rounded, color: AppColors.secondary),
              ),
          ],
        ),
      ),
    );
  }
}
