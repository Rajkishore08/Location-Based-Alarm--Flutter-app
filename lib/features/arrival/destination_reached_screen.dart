import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/models/journey_feedback.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/app_buttons.dart';

class DestinationReachedScreen extends ConsumerStatefulWidget {
  const DestinationReachedScreen({super.key});

  @override
  ConsumerState<DestinationReachedScreen> createState() => _DestinationReachedScreenState();
}

class _DestinationReachedScreenState extends ConsumerState<DestinationReachedScreen> {
  AlertTimingFeedback? _selectedFeedback;

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeJourneyProvider);
    final history = ref.watch(journeyHistoryProvider);
    final journey = activeState.journey ?? (history.isNotEmpty ? history.first : null);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Destination Reached'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 54),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Arrived Safely!',
              style: AppTypography.headlineLg.copyWith(fontSize: 28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              journey?.destination.name ?? 'Destination',
              style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Journey Summary Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
                borderRadius: AppRadius.borderXl,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Distance Covered', style: AppTypography.bodyMd.copyWith(color: AppColors.outline)),
                      Text(
                        '${((journey?.distanceTravelledMeters ?? 12000) / 1000.0).toStringAsFixed(1)} km',
                        style: AppTypography.statsSm,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Trigger Mode', style: AppTypography.bodyMd.copyWith(color: AppColors.outline)),
                      Text(
                        journey?.alertConfiguration.mode.name ?? 'smartAlert',
                        style: AppTypography.statsSm,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Adaptive Feedback Section
            Text(
              'WAS THE ALERT TIMING RIGHT?',
              style: AppTypography.labelMd.copyWith(
                color: isDark ? AppColors.primaryFixed : AppColors.primaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your feedback trains your personalized alarm adaptation engine.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.outline, fontSize: 13),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildFeedbackOption(
                    timing: AlertTimingFeedback.tooEarly,
                    label: 'Too Early',
                    icon: Icons.history_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildFeedbackOption(
                    timing: AlertTimingFeedback.perfect,
                    label: 'Perfect',
                    icon: Icons.thumb_up_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildFeedbackOption(
                    timing: AlertTimingFeedback.tooLate,
                    label: 'Too Late',
                    icon: Icons.update_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            AppPrimaryButton(
              text: 'Finish & Save',
              onPressed: () async {
                if (_selectedFeedback != null) {
                  await ref.read(activeJourneyProvider.notifier).submitFeedback(_selectedFeedback!);
                }
                if (context.mounted) {
                  context.go('/home');
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackOption({
    required AlertTimingFeedback timing,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _selectedFeedback == timing;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectedFeedback = timing),
      borderRadius: AppRadius.borderXl,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : (isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow),
          borderRadius: AppRadius.borderXl,
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: isSelected ? Colors.white : (isDark ? AppColors.inverseOnSurface : AppColors.onSurface),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
