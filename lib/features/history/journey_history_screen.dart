import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/app_bottom_nav.dart';

class JourneyHistoryScreen extends ConsumerWidget {
  const JourneyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(journeyHistoryProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded, size: 64, color: AppColors.outline),
                  const SizedBox(height: AppSpacing.md),
                  Text('No Journey History Yet', style: AppTypography.headlineMd),
                  const SizedBox(height: 4),
                  Text('Your completed journeys will be saved here.', style: AppTypography.bodyLg.copyWith(color: AppColors.outline)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              itemCount: history.length,
              separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, idx) {
                final jny = history[idx];
                final dateStr = DateFormat('MMM d, y • h:mm a').format(jny.startedAt);
                final distKm = (jny.distanceTravelledMeters / 1000.0).toStringAsFixed(1);

                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
                    borderRadius: AppRadius.borderXl,
                    border: Border.all(
                      color: isDark ? AppColors.glassBorderDark : AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateStr,
                            style: AppTypography.labelMd.copyWith(color: AppColors.primary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: AppRadius.borderFull,
                            ),
                            child: Text(
                              'Completed',
                              style: AppTypography.labelMd.copyWith(color: AppColors.success, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        jny.destination.name,
                        style: AppTypography.headlineMd.copyWith(
                          color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        jny.destination.address,
                        style: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Icon(Icons.straighten_rounded, size: 16, color: AppColors.outline),
                          const SizedBox(width: 4),
                          Text('$distKm km', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(width: AppSpacing.lg),
                          Icon(Icons.alarm_rounded, size: 16, color: AppColors.outline),
                          const SizedBox(width: 4),
                          Text(jny.alertConfiguration.mode.name, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (idx) {
          if (idx == 0) context.go('/home');
          if (idx == 2) context.go('/saved');
          if (idx == 3) context.go('/profile');
        },
      ),
    );
  }
}
