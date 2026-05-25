import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class SystemUiAdapter {
  SystemUiAdapter._();

  static SystemUiOverlayStyle _forBrightness(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark ? AppColors.bgBase : AppColors.bgBaseLight,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }

  /// Applique le SystemUiOverlayStyle correct selon le ThemeMode actif.
  /// ThemeMode.system → utilise la luminosité plateforme courante.
  static void apply(ThemeMode mode) {
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final brightness = switch (mode) {
      ThemeMode.dark => Brightness.dark,
      ThemeMode.light => Brightness.light,
      ThemeMode.system => platformBrightness,
    };
    SystemChrome.setSystemUIOverlayStyle(_forBrightness(brightness));
  }
}
