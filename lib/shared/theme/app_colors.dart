import 'package:flutter/material.dart';

/// ZetuCRM Theme Palette — Matched to Laravel web (`palette.ts`)
abstract class AppColors {
  // Primary Blue Palette (#2563EB)
  static const Color primaryLighter = Color(0xFFDBEAFE);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryDarker = Color(0xFF1E3A8A);

  // Secondary Blue / Indigo
  static const Color secondary = Color(0xFF3366FF);

  // Neutral / Grey Scale (Light & Dark)
  static const Color grey0 = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF9FAFB);
  static const Color grey200 = Color(0xFFF4F6F8);
  static const Color grey300 = Color(0xFFDFE3E8);
  static const Color grey400 = Color(0xFFC4CDD5);
  static const Color grey500 = Color(0xFF919EAB);
  static const Color grey600 = Color(0xFF637381);
  static const Color grey700 = Color(0xFF454F5B);
  static const Color grey800 = Color(0xFF212B36);
  static const Color grey900 = Color(0xFF161C24);

  // Dark Canvas & Surface
  static const Color darkCanvas = Color(0xFF161C24);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color darkBorder = Color(0xFF282828);
  static const Color darkInput = Color(0xFF222222);

  // Status & Semantic Colors
  static const Color success = Color(0xFF36B37E);
  static const Color successLighter = Color(0xFFD8FBDE);
  static const Color warning = Color(0xFFFFAB00);
  static const Color warningLighter = Color(0xFFFFF5CC);
  static const Color error = Color(0xFFFF5630);
  static const Color errorLighter = Color(0xFFFFE9D5);
  static const Color info = Color(0xFF00B8D9);
  static const Color infoLighter = Color(0xFFCAFDF5);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF282828);
}
