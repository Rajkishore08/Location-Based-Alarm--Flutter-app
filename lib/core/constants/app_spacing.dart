import 'package:flutter/material.dart';

/// Stitch Spacing and Border Radius Tokens
class AppSpacing {
  AppSpacing._();

  static const double unit = 4.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double gutter = 12.0;
  static const double md = 16.0;
  static const double containerMargin = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  AppRadius._();

  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(full));
}
