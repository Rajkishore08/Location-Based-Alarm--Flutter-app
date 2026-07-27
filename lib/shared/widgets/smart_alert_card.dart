import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class SmartAlertCard extends StatelessWidget {
  final String statusText;
  final String mainTitle;
  final String etaText;
  final IconData icon;

  const SmartAlertCard({
    super.key,
    this.statusText = 'SMART ALERT ACTIVE',
    required this.mainTitle,
    required this.etaText,
    this.icon = Icons.notifications_active_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: AppRadius.borderXl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassDarkBg : AppColors.glassLightBg,
            borderRadius: AppRadius.borderXl,
            border: Border.all(
              color: isDark ? AppColors.primaryFixed.withValues(alpha: 0.4) : AppColors.primaryContainer,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: isDark ? 0.35 : 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.borderLg,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      statusText.toUpperCase(),
                      style: AppTypography.labelMd.copyWith(
                        color: isDark ? AppColors.primaryFixed : AppColors.primaryContainer,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mainTitle,
                      style: AppTypography.headlineMd.copyWith(
                        fontSize: 18,
                        color: isDark ? Colors.white : AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  etaText,
                  style: AppTypography.labelMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
