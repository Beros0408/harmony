import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// Extension pour accéder aux couleurs Harmony depuis n'importe quel contexte
extension HarmonyTheme on ThemeData {
  bool get isOled => scaffoldBackgroundColor == AppColors.bgBaseOled;
}
