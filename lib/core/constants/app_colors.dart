import 'package:flutter/material.dart';

/// Ultra-Modern SaaS Design Tokens for Smart Route Alert
class AppColors {
  AppColors._();

  // Primary Brand & Electric Accents
  static const Color primary = Color(0xFF6366F1); // Electric Indigo
  static const Color primaryContainer = Color(0xFF4F46E5); // Royal Indigo
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFE0E7FF);
  static const Color primaryFixed = Color(0xFF818CF8);
  static const Color primaryFixedDim = Color(0xFF6366F1);
  static const Color onPrimaryFixed = Color(0xFF1E1B4B);
  static const Color onPrimaryFixedVariant = Color(0xFF3730A3);

  // Secondary Accents (Sky Cyan & Cobalt)
  static const Color secondary = Color(0xFF38BDF8); // Sky Cyan
  static const Color secondaryContainer = Color(0xFF0284C7);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFFF0F9FF);
  static const Color secondaryFixed = Color(0xFFBAE6FD);
  static const Color secondaryFixedDim = Color(0xFF7DD3FC);
  static const Color onSecondaryFixed = Color(0xFF0C4A6E);
  static const Color onSecondaryFixedVariant = Color(0xFF0369A1);

  // Tertiary Accents (Purple Neon)
  static const Color tertiary = Color(0xFFC084FC); // Purple Neon
  static const Color tertiaryContainer = Color(0xFF9333EA);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFFAF5FF);

  // Neutral & Deep Space Canvas (Dark Mode Default)
  static const Color background = Color(0xFF0B0F19); // Deep Space Canvas
  static const Color onBackground = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFF0F172A); // Slate Surface
  static const Color onSurface = Color(0xFFF8FAFC);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);

  static const Color surfaceContainerLowest = Color(0xFF070A12);
  static const Color surfaceContainerLow = Color(0xFF1E293B);
  static const Color surfaceContainer = Color(0xFF1E2638);
  static const Color surfaceContainerHigh = Color(0xFF334155);
  static const Color surfaceContainerHighest = Color(0xFF475569);
  static const Color surfaceDim = Color(0xFF0F172A);
  static const Color surfaceBright = Color(0xFF1E293B);
  static const Color surfaceTint = Color(0xFF6366F1);

  // Inverse Colors (Light Mode Adaptability)
  static const Color inverseSurface = Color(0xFFF8FAFC);
  static const Color inverseOnSurface = Color(0xFF0F172A);
  static const Color inversePrimary = Color(0xFF4F46E5);

  // Outlines & Glowing Glass Borders
  static const Color outline = Color(0xFF64748B);
  static const Color outlineVariant = Color(0xFF334155);

  // Errors & Critical Alerts
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFF450A0A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFFFCA5A5);

  // High-Contrast Status Indicators
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber Warning
  static const Color info = Color(0xFF38BDF8); // Cyan Info

  // Glassmorphic Surfaces & Radial Glows
  static const Color glassLightBg = Color(0xE6FFFFFF); // 90% blur white
  static const Color glassDarkBg = Color(0xD90F172A); // 85% blur deep slate
  static const Color glassBorderLight = Color(0x336366F1);
  static const Color glassBorderDark = Color(0x4038BDF8); // 25% glowing cyan border

  // SaaS Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient heroRadialGlow = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.2,
    colors: [Color(0x336366F1), Color(0x1A38BDF8), Color(0x000B0F19)],
  );
}
