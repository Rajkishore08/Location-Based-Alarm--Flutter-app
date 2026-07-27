import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/app_buttons.dart';

class FullScreenAlarmScreen extends ConsumerStatefulWidget {
  const FullScreenAlarmScreen({super.key});

  @override
  ConsumerState<FullScreenAlarmScreen> createState() => _FullScreenAlarmScreenState();
}

class _FullScreenAlarmScreenState extends ConsumerState<FullScreenAlarmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeJourneyProvider);
    final journey = activeState.journey;
    final alarmService = ref.watch(alarmServiceProvider);
    final int escalationStage = alarmService.escalationStage;

    final double distKm = (journey?.distanceRemainingMeters ?? 2100) / 1000.0;
    final int etaMins = (journey?.alertTriggeredEta?.inMinutes) ?? 3;

    return Scaffold(
      backgroundColor: escalationStage == 3 ? const Color(0xFF2B0000) : AppColors.inverseSurface,
      body: Stack(
        children: [
          // Radial Urgency Glow Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    AppColors.primaryContainer.withValues(alpha: 0.25),
                    escalationStage == 3
                        ? AppColors.error.withValues(alpha: 0.2)
                        : Colors.transparent,
                    AppColors.inverseSurface,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin, vertical: AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Status Header
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.2),
                          borderRadius: AppRadius.borderFull,
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          escalationStage == 3 ? 'EMERGENCY ALERT (STAGE 3)' : 'EMERGENCY ALERT',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.errorContainer,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'DESTINATION APPROACHING',
                        style: AppTypography.headlineLgMobile.copyWith(
                          color: AppColors.inverseOnSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  // Center Pulsing Visual & Location Summary
                  Column(
                    children: [
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryContainer.withValues(alpha: 0.6),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: Colors.white,
                            size: 72,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text(
                        journey?.destination.name ?? 'Chennai Central',
                        style: AppTypography.headlineLg.copyWith(
                          color: AppColors.inversePrimary,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.straighten_rounded, size: 16, color: AppColors.outlineVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${distKm.toStringAsFixed(1)} km away',
                            style: AppTypography.statsSm.copyWith(color: AppColors.outlineVariant),
                          ),
                          const SizedBox(width: 12),
                          Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.outline, shape: BoxShape.circle)),
                          const SizedBox(width: 12),
                          const Icon(Icons.schedule_rounded, size: 16, color: AppColors.outlineVariant),
                          const SizedBox(width: 4),
                          Text(
                            '~$etaMins min',
                            style: AppTypography.statsSm.copyWith(color: AppColors.outlineVariant),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Bottom Interaction Buttons
                  Column(
                    children: [
                      AppPrimaryButton(
                        text: "I'M AWAKE",
                        icon: Icons.verified_rounded,
                        height: 60,
                        onPressed: () async {
                          await ref.read(activeJourneyProvider.notifier).acknowledgeAlarm();
                          if (context.mounted) {
                            context.go('/arrival');
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      AppSecondaryButton(
                        text: 'SNOOZE 1 MIN',
                        icon: Icons.snooze_rounded,
                        onPressed: () async {
                          await ref.read(activeJourneyProvider.notifier).snoozeAlarm();
                          if (context.mounted) {
                            context.go('/journey');
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      TextButton.icon(
                        onPressed: () async {
                          await ref.read(activeJourneyProvider.notifier).stopJourney();
                          if (context.mounted) context.go('/home');
                        },
                        icon: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
                        label: Text(
                          'Stop Alarm',
                          style: AppTypography.labelMd.copyWith(color: AppColors.error, letterSpacing: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
