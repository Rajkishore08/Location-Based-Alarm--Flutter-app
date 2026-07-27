import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class LocationSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onMicTap;
  final String hintText;
  final bool readOnly;

  const LocationSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onMicTap,
    this.hintText = 'Where do you want to wake up?',
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: isDark ? AppColors.glassBorderDark : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        style: AppTypography.bodyLg.copyWith(
          color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyLg.copyWith(
            color: isDark ? AppColors.outlineVariant : AppColors.outline,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.outline),
          suffixIcon: IconButton(
            icon: const Icon(Icons.mic_rounded, color: AppColors.primary),
            onPressed: onMicTap,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        ),
      ),
    );
  }
}
