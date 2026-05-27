import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppLightTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A1C2E),
        primary: const Color(0xFF1A1C2E),
        secondary: const Color(0xFF4B7399),
        surface: Colors.white,
        surfaceContainerLowest: const Color(0xFFF8F9FE),
      ),

      scaffoldBackgroundColor: const Color(
        0xFFF8F9FE,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF8F9FE),
        foregroundColor: const Color(0xFF1A1C2E),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 20.sp,
          letterSpacing: 1.2,
          color: const Color(0xFF1A1C2E),
        ),
      ),
    );
  }
}