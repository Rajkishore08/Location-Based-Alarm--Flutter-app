import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Stitch Typography Tokens using Inter font family
class AppTypography {
  AppTypography._();

  static TextStyle get displayData => GoogleFonts.inter(
        fontSize: 48,
        height: 56 / 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.96,
      );

  static TextStyle get headlineLg => GoogleFonts.inter(
        fontSize: 30,
        height: 38 / 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  static TextStyle get headlineLgMobile => GoogleFonts.inter(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      );

  static TextStyle get headlineMd => GoogleFonts.inter(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get statsSm => GoogleFonts.inter(
        fontSize: 18,
        height: 22 / 18,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      );

  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w500,
      );
}
