import 'package:flutter/material.dart';

/// Domain-level filter mode enum — distinct from [FilterModeType] in security_mocks.dart
/// which is a UI-only model. HarmonyFilterMode drives the native engine.
enum HarmonyFilterMode {
  off,
  night,
  work,
  focus,
  weekend,
  emergency,
}

/// Descriptor for a HarmonyFilterMode shown in the UI.
class HarmonyFilterModeConfig {
  const HarmonyFilterModeConfig({
    required this.mode,
    required this.icon,
    required this.color,
    required this.labelKey,
    required this.descriptionKey,
  });

  final HarmonyFilterMode mode;
  final IconData icon;
  final Color color;
  final String labelKey;       // i18n key for AppLocalizations
  final String descriptionKey; // i18n key for description
}

/// All five predefined modes + off.
const kHarmonyFilterModes = [
  HarmonyFilterModeConfig(
    mode: HarmonyFilterMode.off,
    icon: Icons.shield_outlined,
    color: Color(0xFF64748B),
    labelKey: 'filterModeOff',
    descriptionKey: 'filterModeOffDesc',
  ),
  HarmonyFilterModeConfig(
    mode: HarmonyFilterMode.night,
    icon: Icons.nightlight_outlined,
    color: Color(0xFF818CF8),
    labelKey: 'filterModeNight',
    descriptionKey: 'filterModeNightDesc',
  ),
  HarmonyFilterModeConfig(
    mode: HarmonyFilterMode.work,
    icon: Icons.work_outline_rounded,
    color: Color(0xFF38BDF8),
    labelKey: 'filterModeWork',
    descriptionKey: 'filterModeWorkDesc',
  ),
  HarmonyFilterModeConfig(
    mode: HarmonyFilterMode.focus,
    icon: Icons.do_not_disturb_on_outlined,
    color: Color(0xFFFBBF24),
    labelKey: 'filterModeFocus',
    descriptionKey: 'filterModeFocusDesc',
  ),
  HarmonyFilterModeConfig(
    mode: HarmonyFilterMode.weekend,
    icon: Icons.weekend_outlined,
    color: Color(0xFF34D399),
    labelKey: 'filterModeWeekend',
    descriptionKey: 'filterModeWeekendDesc',
  ),
  HarmonyFilterModeConfig(
    mode: HarmonyFilterMode.emergency,
    icon: Icons.emergency_outlined,
    color: Color(0xFFF87171),
    labelKey: 'filterModeEmergency',
    descriptionKey: 'filterModeEmergencyDesc',
  ),
];

/// Manages active filter mode state (in-memory for MVP).
/// Call [activate] to switch modes; [current] reflects the active one.
class FilterModeManager extends ChangeNotifier {
  HarmonyFilterMode _current = HarmonyFilterMode.off;

  HarmonyFilterMode get current => _current;

  void activate(HarmonyFilterMode mode) {
    if (_current == mode) return;
    _current = mode;
    notifyListeners();
  }

  /// Maps [HarmonyFilterMode] to the string value accepted by Kotlin CallDecisionEngine.
  String toNativeValue(HarmonyFilterMode mode) => switch (mode) {
        HarmonyFilterMode.off => 'normal',
        HarmonyFilterMode.night => 'night',
        HarmonyFilterMode.work => 'work',
        HarmonyFilterMode.focus => 'focus',
        HarmonyFilterMode.weekend => 'weekend',
        HarmonyFilterMode.emergency => 'emergency',
      };
}
