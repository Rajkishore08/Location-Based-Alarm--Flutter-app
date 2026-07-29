import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// World-Class AI SaaS Typography Hierarchy
/// Uses Inter font family with SF Pro / Linear styling proportions
class AppTypography {
  AppTypography._();

  // Hero Display: 32 - 36px
  static TextStyle get hero => GoogleFonts.inter(
        fontSize: 34,
        height: 42 / 34,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.0,
      );

  // Section Titles: 22px
  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      );

  // Cards: 18px
  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  // Body: 15 - 16px
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w500,
      );

  // Captions: 13px
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
      );

  // Backward-compatibility aliases
  static TextStyle get displayData => hero;
  static TextStyle get headlineLg => hero;
  static TextStyle get headlineLgMobile => hero.copyWith(fontSize: 28);
  static TextStyle get headlineMd => sectionTitle;
  static TextStyle get bodyLg => body.copyWith(fontSize: 16);
  static TextStyle get bodyMd => body;
  static TextStyle get statsSm => cardTitle;
  static TextStyle get labelMd => caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.8);
  static TextStyle get labelSm => caption.copyWith(fontSize: 11);
}
