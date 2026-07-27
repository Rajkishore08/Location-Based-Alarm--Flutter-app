import 'package:flutter/material.dart';

/// Stitch Design System Color Palette for Smart Route Alert
/// Visual Source of Truth: Stitch Project 15343939883169592414
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF3525CD);
  static const Color primaryContainer = Color(0xFF4F46E5);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFDAD7FF);
  static const Color primaryFixed = Color(0xFFE2DFFF);
  static const Color primaryFixedDim = Color(0xFFC3C0FF);
  static const Color onPrimaryFixed = Color(0xFF0F0069);
  static const Color onPrimaryFixedVariant = Color(0xFF3323CC);

  // Secondary Colors
  static const Color secondary = Color(0xFF0051D5);
  static const Color secondaryContainer = Color(0xFF316BF3);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFFFEFCFF);
  static const Color secondaryFixed = Color(0xFFDBE1FF);
  static const Color secondaryFixedDim = Color(0xFFB4C5FF);
  static const Color onSecondaryFixed = Color(0xFF00174B);
  static const Color onSecondaryFixedVariant = Color(0xFF003EA8);

  // Tertiary Colors
  static const Color tertiary = Color(0xFF5C00CA);
  static const Color tertiaryContainer = Color(0xFF7531E6);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFE4D4FF);
  static const Color tertiaryFixed = Color(0xFFEADDFF);
  static const Color tertiaryFixedDim = Color(0xFFD2BBFF);
  static const Color onTertiaryFixed = Color(0xFF25005A);
  static const Color onTertiaryFixedVariant = Color(0xFF5A00C6);

  // Neutral & Surface Colors (Light Mode)
  static const Color background = Color(0xFFFAF8FF);
  static const Color onBackground = Color(0xFF131B2E);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF464555);

  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color surfaceContainerHighest = Color(0xFFDAE2FD);
  static const Color surfaceDim = Color(0xFFD2D9F4);
  static const Color surfaceBright = Color(0xFFFAF8FF);
  static const Color surfaceTint = Color(0xFF4D44E3);

  // Inverse Colors (Dark Mode Base)
  static const Color inverseSurface = Color(0xFF283044);
  static const Color inverseOnSurface = Color(0xFFEEF0FF);
  static const Color inversePrimary = Color(0xFFC3C0FF);

  // Outlines & Borders
  static const Color outline = Color(0xFF777587);
  static const Color outlineVariant = Color(0xFFC7C4D8);

  // Errors & Warnings
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Status Indicator Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Glassmorphic Overlays
  static const Color glassLightBg = Color(0xB3FAF8FF); // 70% opacity
  static const Color glassDarkBg = Color(0xB3283044); // 70% opacity
  static const Color glassBorderLight = Color(0x33C7C4D8);
  static const Color glassBorderDark = Color(0x1AFFFFFF);
}
