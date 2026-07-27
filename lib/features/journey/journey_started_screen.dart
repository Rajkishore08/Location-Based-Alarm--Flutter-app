import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/app_buttons.dart';

class JourneyStartedScreen extends ConsumerWidget {
  const JourneyStartedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeState = ref.watch(activeJourneyProvider);
    final journey = activeState.journey;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 64,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Journey Started!',
                style: AppTypography.headlineLg.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Smart Route Alert is now actively tracking your route to ${journey?.destination.name ?? 'your destination'}.',
                style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadius.borderXl,
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.primaryContainer),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Background Location Active. Screen can now be safely locked or app backgrounded.',
                        style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppPrimaryButton(
                text: 'View Live Journey',
                onPressed: () => context.go('/journey'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
