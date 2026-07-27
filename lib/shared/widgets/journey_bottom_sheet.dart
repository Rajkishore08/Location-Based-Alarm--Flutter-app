import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../models/journey.dart';
import '../models/smart_alert_decision.dart';
import 'app_buttons.dart';
import 'status_chip.dart';

class JourneyBottomSheet extends StatelessWidget {
  final Journey journey;
  final VoidCallback onStopJourney;
  final VoidCallback onDetailsTap;
  final VoidCallback? onSnoozeTap;

  const JourneyBottomSheet({
    super.key,
    required this.journey,
    required this.onStopJourney,
    required this.onDetailsTap,
    this.onSnoozeTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double distKm = journey.distanceRemainingMeters / 1000.0;
    final String etaString = journey.estimatedArrival != null
        ? '${journey.estimatedArrival!.hour.toString().padLeft(2, '0')}:${journey.estimatedArrival!.minute.toString().padLeft(2, '0')}'
        : '--:--';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inverseSurface : AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxl),
          topRight: Radius.circular(AppRadius.xxl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.outlineVariant : AppColors.outlineVariant.withValues(alpha: 0.5),
                borderRadius: AppRadius.borderFull,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Destination Header & Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NAVIGATING TO',
                      style: AppTypography.labelMd.copyWith(
                        color: isDark ? AppColors.outlineVariant : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      journey.destination.name,
                      style: AppTypography.headlineMd.copyWith(
                        color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusChip(status: _mapJourneyStatus(journey.status)),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Key Metrics Grid (Distance, ETA, Speed)
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: 'DISTANCE',
                  value: '${distKm.toStringAsFixed(1)} km',
                  icon: Icons.straighten_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: 'EST. ARRIVAL',
                  value: etaString,
                  icon: Icons.schedule_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: 'SPEED',
                  value: '${journey.currentSpeedKmh.toStringAsFixed(0)} km/h',
                  icon: Icons.speed_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Primary Actions (Stop Journey, Details, Snooze if alarm active)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppPrimaryButton(
                  text: 'End Journey',
                  backgroundColor: AppColors.error,
                  icon: Icons.stop_circle_rounded,
                  onPressed: onStopJourney,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppSecondaryButton(
                  text: 'Details',
                  icon: Icons.info_outline_rounded,
                  onPressed: onDetailsTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
        borderRadius: AppRadius.borderXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelMd.copyWith(
                    fontSize: 10,
                    color: isDark ? AppColors.outlineVariant : AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.statsSm.copyWith(
              color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  SmartAlertStatus _mapJourneyStatus(JourneyStatus s) {
    switch (s) {
      case JourneyStatus.recalculating:
        return SmartAlertStatus.recalculating;
      case JourneyStatus.routeDeviation:
        return SmartAlertStatus.routeDeviation;
      case JourneyStatus.approaching:
        return SmartAlertStatus.destinationNear;
      case JourneyStatus.alarmTriggered:
      case JourneyStatus.alarmEscalated:
        return SmartAlertStatus.triggerAlert;
      case JourneyStatus.completed:
        return SmartAlertStatus.arrived;
      default:
        return SmartAlertStatus.trackingNormally;
    }
  }
}
