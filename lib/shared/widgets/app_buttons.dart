import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final Color? backgroundColor;
  final double height;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.backgroundColor,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderXl,
        gradient: backgroundColor != null
            ? null
            : const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF3525CD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? const Color(0xFF4F46E5)).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppRadius.borderXl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: AppTypography.bodyLg.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Icon(icon, size: 22, color: Colors.white),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double height;

  const AppSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: isDark ? AppColors.glassBorderDark : AppColors.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.borderXl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: isDark ? AppColors.inverseOnSurface : AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  text,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.inverseOnSurface : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
