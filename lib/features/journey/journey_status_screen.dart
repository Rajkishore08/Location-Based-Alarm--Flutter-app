import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/providers/app_providers.dart';

class JourneyStatusScreen extends ConsumerWidget {
  const JourneyStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeState = ref.watch(activeJourneyProvider);
    final journey = activeState.journey;
    final decision = activeState.decision;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (journey == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Journey Details')),
        body: const Center(child: Text('No active journey')),
      );
    }

    final double distRemainingKm = journey.distanceRemainingMeters / 1000.0;
    final double distTravelledKm = journey.distanceTravelledMeters / 1000.0;
    final double confidence = decision?.confidence ?? 0.85;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Status & Metrics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Title Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
                borderRadius: AppRadius.borderXl,
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.primaryContainer, size: 32),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          journey.destination.name,
                          style: AppTypography.headlineMd.copyWith(
                            color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          journey.destination.address,
                          style: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Smart Alert Confidence Gauge
            Text(
              'SMART ALERT ENGINE PREDICTION',
              style: AppTypography.labelMd.copyWith(
                color: isDark ? AppColors.primaryFixed : AppColors.primaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
                borderRadius: AppRadius.borderXl,
                border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Alert Confidence Score',
                        style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${(confidence * 100).toStringAsFixed(0)}%',
                        style: AppTypography.headlineMd.copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: AppRadius.borderFull,
                    child: LinearProgressIndicator(
                      value: confidence,
                      minHeight: 10,
                      backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    decision?.reason ?? 'Continuous GPS monitoring active.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Metrics Grid
            Text(
              'LIVE TRAVEL METRICS',
              style: AppTypography.labelMd.copyWith(
                color: isDark ? AppColors.primaryFixed : AppColors.primaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    context,
                    title: 'Current Speed',
                    value: '${journey.currentSpeedKmh.toStringAsFixed(0)} km/h',
                    icon: Icons.speed_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildDetailTile(
                    context,
                    title: 'Distance Left',
                    value: '${distRemainingKm.toStringAsFixed(1)} km',
                    icon: Icons.straighten_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    context,
                    title: 'Distance Travelled',
                    value: '${distTravelledKm.toStringAsFixed(1)} km',
                    icon: Icons.route_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildDetailTile(
                    context,
                    title: 'Trigger Mode',
                    value: journey.alertConfiguration.mode.name,
                    icon: Icons.notifications_active_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(
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
          Icon(icon, color: AppColors.primaryContainer, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTypography.labelMd.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: 2),
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
}
