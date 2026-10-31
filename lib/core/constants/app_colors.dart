import 'package:flutter/material.dart';

/// Design tokens and semantic colors for Grandmaster Chess.
/// Inspired by tournament chessboards (Chess.com, Lichess, physical wooden sets).
abstract class AppColors {
  // Brand / Action Accents
  // Vibrant Chess Emerald - the iconic action color across master chess platforms
  static const primaryGreen = Color(0xFF81B64C);
  static const primaryGreenDark = Color(0xFF629924);
  static const primaryGreenLight = Color(0xFF96CC5B);

  // Royal Grandmaster Amber Gold - for crowns, ratings, trophies, and badges
  static const accentGold = Color(0xFFF59E0B);
  static const accentGoldLight = Color(0xFFFBBF24);

  // Dark Theme Palette (Obsidian / Graphite / Slate)
  static const darkBackground = Color(0xFF121316); // Deep canvas, zero eye strain
  static const darkSurface = Color(0xFF1B1E24); // Card surfaces
  static const darkSurfaceElevated = Color(0xFF232732); // Modals, sheets, dialogs
  static const darkBorder = Color(0xFF2A2F3D); // Clean subtle component borders
  static const darkTextPrimary = Color(0xFFF3F4F6); // Soft off-white
  static const darkTextSecondary = Color(0xFF94A3B8); // Slate muted

  // Light Theme Palette (Parchment / Marble / Clean Slate)
  static const lightBackground = Color(0xFFF6F7F9);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceElevated = Color(0xFFF1F5F9);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);

  // Tournament Chessboard Palette
  // Standard Tournament Olive-Wood
  static const boardWoodLight = Color(0xFFEEEED2); // Natural parchment cream
  static const boardWoodDark = Color(0xFF769656); // Official Chess.com sage olive

  // Midnight Analytical Slate
  static const boardMidnightLight = Color(0xFFDEE3E6);
  static const boardMidnightDark = Color(0xFF4B7399);

  // Interactive Highlights
  static const squareSelected = Color(0xB3F7E04C); // Warm amber highlight
  static const squareLastMove = Color(0x6660A5FA); // Cool cyan-blue trace
  static const squareCheck = Color(0xB3EF4444); // Crimson check warning
  static const moveDot = Color(0x38000000);

  // Semantic Feedback
  static const success = Color(0xFF10B981); // Emerald
  static const warning = Color(0xFFF59E0B); // Amber
  static const error = Color(0xFFEF4444); // Red
}
