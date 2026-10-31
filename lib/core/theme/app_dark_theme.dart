import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/constants/app_colors.dart';

class AppDarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        brightness: Brightness.dark,
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentGold,
        surface: AppColors.darkSurface,
        surfaceContainerHighest: AppColors.darkSurfaceElevated,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkBorder,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.2),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 20.sp,
          letterSpacing: 0.5,
          color: AppColors.darkTextPrimary,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.2),
        ),
      ),
    );
  }
}
