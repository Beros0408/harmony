import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum DayModeType { focus, sleep }

enum EventType { meeting, dinner, yoga }

class DayMode {
  final DayModeType type;
  final IconData icon;
  final Color color;
  final bool defaultEnabled;
  const DayMode({
    required this.type,
    required this.icon,
    required this.color,
    required this.defaultEnabled,
  });
}

class AgendaEvent {
  final EventType type;
  final Color accentColor;
  final IconData detailIcon;
  const AgendaEvent({required this.type, required this.accentColor, required this.detailIcon});
}

const kDayModes = [
  DayMode(type: DayModeType.focus, icon: Icons.headphones, color: AppColors.accentBlue, defaultEnabled: true),
  DayMode(type: DayModeType.sleep, icon: Icons.bedtime, color: AppColors.accentPurple, defaultEnabled: false),
];

const kTodayEvents = [
  AgendaEvent(type: EventType.meeting, accentColor: AppColors.accentBlue, detailIcon: Icons.people),
  AgendaEvent(type: EventType.dinner, accentColor: AppColors.accentGreen, detailIcon: Icons.location_on),
  AgendaEvent(type: EventType.yoga, accentColor: AppColors.accentAmber, detailIcon: Icons.fitness_center),
];
