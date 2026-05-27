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
  static const Color accentRose = Color(0xFFEC4899);

  // --- OLED (noir pur) ---
  static const Color bgBaseOled = Color(0xFF000000);

  // Blanc pur — utilisé pour les thumbs de toggles et icônes sur fond coloré
  static const Color white = Color(0xFFFFFFFF);

  // --- Light mode (anti-fatigue ivoire chaud) ---
  static const Color bgBaseLight = Color(0xFFFAF8F5);
  static const Color bgSurfaceLight = Color(0xFFFFFFFF);
  static const Color bgElevatedLight = Color(0xFFF9F9FB);
  static const Color bgInteractiveLight = Color(0xFFF1F3F8);

  static const Color borderSubtleLight = Color(0xFFE5E7EB);
  static const Color borderDefaultLight = Color(0xFFD1D5DB);
  static const Color borderStrongLight = Color(0xFF9CA3AF);

  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF4B5563);
  static const Color textMutedLight = Color(0xFF9CA3AF);
  static const Color textInverseLight = Color(0xFFFFFFFF);

  // --- Badges light mode (WCAG AAA — fond pastel + texte sombre) ---
  static const Color badgeSuccessBgLight = Color(0xFFD1FAE5);
  static const Color badgeSuccessTextLight = Color(0xFF065F46);
  static const Color badgeWarningBgLight = Color(0xFFFEF3C7);
  static const Color badgeWarningTextLight = Color(0xFF92400E);
  static const Color badgeDangerBgLight = Color(0xFFFEE2E2);
  static const Color badgeDangerTextLight = Color(0xFF991B1B);
  static const Color badgeInfoBgLight = Color(0xFFDBEAFE);
  static const Color badgeInfoTextLight = Color(0xFF1E40AF);
  static const Color badgePurpleBgLight = Color(0xFFEDE9FE);
  static const Color badgePurpleTextLight = Color(0xFF5B21B6);
  static const Color badgeMutedBgLight = Color(0xFFF3F4F6);
  static const Color badgeMutedTextLight = Color(0xFF374151);
  static const Color badgeRoseBgLight = Color(0xFFFCE7F3);
  static const Color badgeRoseTextLight = Color(0xFF9D174D);
}
