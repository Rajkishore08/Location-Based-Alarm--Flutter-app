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
    return ClipRRect(
      borderRadius: AppRadius.borderXl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.borderXl,
            border: Border.all(
              color: AppColors.secondary,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryContainer, AppColors.secondary],
                  ),
                  borderRadius: AppRadius.borderLg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.5),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: AppColors.success, blurRadius: 6),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText.toUpperCase(),
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mainTitle,
                      style: AppTypography.headlineMd.copyWith(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondaryContainer, AppColors.primaryContainer],
                  ),
                  borderRadius: AppRadius.borderFull,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  etaText,
                  style: AppTypography.labelMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
