import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0F111A),
        brightness: Brightness.dark,
        primary: const Color(0xFFE2E2FF),
        secondary: const Color(0xFF94A3B8),
        surface: const Color(0xFF0F111A),
        surfaceContainerHighest: const Color(
          0xFF1E293B,
        ),
      ),

      scaffoldBackgroundColor: const Color(
        0xFF0F111A,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F111A),
        foregroundColor: const Color(0xFFE2E2FF),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 20.sp,
          letterSpacing: 1.2,
          color: const Color(0xFFE2E2FF),
        ),
      ),
    );
  }
}