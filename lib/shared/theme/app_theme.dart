import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.grey100,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLighter,
        secondary: AppColors.secondary,
        surface: AppColors.grey0,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.grey800,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.grey0,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: AppColors.grey800),
        titleTextStyle: AppTypography.h4(color: AppColors.grey800),
      ),
      cardTheme: CardThemeData(
        color: AppColors.grey0,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTypography.body1(color: AppColors.grey500),
        labelStyle: AppTypography.body2(color: AppColors.grey600),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.grey0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkCanvas,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryDarker,
        secondary: AppColors.secondary,
        surface: AppColors.darkCard,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: AppTypography.h4(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTypography.body1(color: AppColors.grey600),
        labelStyle: AppTypography.body2(color: AppColors.grey500),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.grey600,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
