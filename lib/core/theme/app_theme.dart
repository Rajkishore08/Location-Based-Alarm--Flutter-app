import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        shadow: Color(0x1F000000),
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMd.copyWith(color: AppColors.primary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
          textStyle: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
          textStyle: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.inversePrimary,
      scaffoldBackgroundColor: AppColors.inverseSurface,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.inversePrimary,
        onPrimary: AppColors.onPrimaryFixed,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondaryFixedDim,
        onSecondary: AppColors.onSecondaryFixed,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiaryFixedDim,
        onTertiary: AppColors.onTertiaryFixed,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.errorContainer,
        onError: AppColors.onErrorContainer,
        surface: AppColors.inverseSurface,
        onSurface: AppColors.inverseOnSurface,
        onSurfaceVariant: AppColors.outlineVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.onSurfaceVariant,
        shadow: Color(0x3F000000),
        inverseSurface: AppColors.surface,
        onInverseSurface: AppColors.onSurface,
        inversePrimary: AppColors.primary,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E2638),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.inverseSurface,
        foregroundColor: AppColors.inverseOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMd.copyWith(color: AppColors.primaryFixed),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
          textStyle: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
