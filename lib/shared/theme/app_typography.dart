import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// ZetuCRM Typography System using Inter Google Fonts
abstract class AppTypography {
  static TextStyle fontPrimary({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.grey800,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // Headings
  static TextStyle h1({Color color = AppColors.grey800}) => fontPrimary(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.25,
      );

  static TextStyle h2({Color color = AppColors.grey800}) => fontPrimary(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.3,
      );

  static TextStyle h3({Color color = AppColors.grey800}) => fontPrimary(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle h4({Color color = AppColors.grey800}) => fontPrimary(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle h5({Color color = AppColors.grey800}) => fontPrimary(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  // Subtitles & Body
  static TextStyle subtitle1({Color color = AppColors.grey800}) => fontPrimary(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.5,
      );

  static TextStyle subtitle2({Color color = AppColors.grey600}) => fontPrimary(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.5,
      );

  static TextStyle body1({Color color = AppColors.grey800}) => fontPrimary(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.5,
      );

  static TextStyle body2({Color color = AppColors.grey600}) => fontPrimary(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.5,
      );

  static TextStyle caption({Color color = AppColors.grey500}) => fontPrimary(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.4,
      );

  static TextStyle overline({Color color = AppColors.grey500}) => fontPrimary(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.4,
      );

  static TextStyle button({Color color = Colors.white}) => fontPrimary(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.4,
      );
}
