import 'package:flutter/material.dart';

/// World-Class AI SaaS Design System Color Palette
/// Inspired by Linear, Notion AI, Perplexity, Arc Browser, Apple Maps, Uber, Raycast
class AppColors {
  AppColors._();

  // Core Palette Tokens
  static const Color background = Color(0xFF070B14); // Deep Space Canvas
  static const Color surface = Color(0xFF101827); // Primary Card Surface
  static const Color surfaceSecondary = Color(0xFF161F33); // Secondary Floating Surface
  static const Color primary = Color(0xFF6C63FF); // Electric Linear Indigo
  static const Color accent = Color(0xFF7F5AF0); // Raycast Purple Accent
  static const Color success = Color(0xFF2DD4BF); // Neon Teal
  static const Color warning = Color(0xFFFBBF24); // Warm Gold
  static const Color danger = Color(0xFFF87171); // Coral Red

  // Text Hierarchy Tokens
  static const Color textPrimary = Color(0xFFFFFFFF); // High-contrast White
  static const Color textSecondary = Color(0xFF94A3B8); // Muted Slate
  static const Color textMuted = Color(0xFF64748B);

  // Borders & Dividers
  static const Color thinBorder = Color(0x14FFFFFF); // 8% Frosted Border
  static const Color glowingBorder = Color(0x406C63FF); // 25% Glowing Indigo
  static const Color cyanBorder = Color(0x332DD4BF); // 20% Teal Border

  // Legacy Compatibility Aliases
  static const Color primaryContainer = Color(0xFF6C63FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color primaryFixed = Color(0xFF7F5AF0);
  static const Color primaryFixedDim = Color(0xFF6C63FF);
  static const Color onPrimaryFixed = Color(0xFF070B14);
  static const Color onPrimaryFixedVariant = Color(0xFF101827);

  static const Color secondary = Color(0xFF2DD4BF);
  static const Color secondaryContainer = Color(0xFF161F33);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFFFFFFFF);

  static const Color tertiary = Color(0xFF7F5AF0);
  static const Color tertiaryContainer = Color(0xFF161F33);
  static const Color onTertiary = Color(0xFFFFFFFF);

  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);

  static const Color surfaceContainerLowest = Color(0xFF05080E);
  static const Color surfaceContainerLow = Color(0xFF101827);
  static const Color surfaceContainer = Color(0xFF161F33);
  static const Color surfaceContainerHigh = Color(0xFF1E293B);
  static const Color surfaceContainerHighest = Color(0xFF334155);
  static const Color surfaceDim = Color(0xFF070B14);
  static const Color surfaceBright = Color(0xFF161F33);
  static const Color surfaceTint = Color(0xFF6C63FF);

  static const Color inverseSurface = Color(0xFFFFFFFF);
  static const Color inverseOnSurface = Color(0xFF070B14);
  static const Color inversePrimary = Color(0xFF6C63FF);

  static const Color outline = Color(0xFF64748B);
  static const Color outlineVariant = Color(0xFF334155);

  static const Color error = Color(0xFFF87171);
  static const Color errorContainer = Color(0xFF450A0A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFFF87171);
  static const Color info = Color(0xFF2DD4BF);

  static const Color glassLightBg = Color(0xE6FFFFFF);
  static const Color glassDarkBg = Color(0xD9101827);
  static const Color glassBorderLight = Color(0x336C63FF);
  static const Color glassBorderDark = Color(0x14FFFFFF);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF7F5AF0), Color(0xFF2DD4BF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    colors: [Color(0xFF101827), Color(0xFF161F33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient heroGlow = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.2,
    colors: [Color(0x336C63FF), Color(0x1A7F5AF0), Color(0x00070B14)],
  );
}
