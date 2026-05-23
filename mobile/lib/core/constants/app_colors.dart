import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Dark mode (par défaut) ---
  static const Color bgBase = Color(0xFF0A0F1E);
  static const Color bgSurface = Color(0xFF0F1729);
  static const Color bgElevated = Color(0xFF1A2236);
  static const Color bgInteractive = Color(0xFF1E2D45);

  static const Color borderSubtle = Color(0xFF1E2D45);
  static const Color borderDefault = Color(0xFF2A3F5F);
  static const Color borderStrong = Color(0xFF3D5A80);

  static const Color textPrimary = Color(0xFFE8EDF5);
  static const Color textSecondary = Color(0xFF8BA3C7);
  static const Color textMuted = Color(0xFF4A6080);
  static const Color textInverse = Color(0xFF0A0F1E);

  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentBlueHover = Color(0xFF2563EB);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);

  // --- OLED (noir pur) ---
  static const Color bgBaseOled = Color(0xFF000000);

  // Blanc pur — utilisé pour les thumbs de toggles et icônes sur fond coloré
  static const Color white = Color(0xFFFFFFFF);

  // --- Light mode (préparé pour la v1) ---
  static const Color bgBaseLight = Color(0xFFFFFFFF);
  static const Color bgSurfaceLight = Color(0xFFF8FAFC);
  static const Color bgElevatedLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
}
