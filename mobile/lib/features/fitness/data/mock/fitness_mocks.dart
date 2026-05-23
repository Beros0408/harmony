import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FitnessStat {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;
  const FitnessStat({
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
    required this.color,
  });
}

class PersonalRecord {
  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  const PersonalRecord({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });
}

class WorkoutSession {
  final IconData icon;
  final String type;
  final String detail;
  const WorkoutSession({
    required this.icon,
    required this.type,
    required this.detail,
  });
}

const kTodayStats = [
  FitnessStat(label: 'Pas', value: '6 247', unit: '/ 8 000 obj.', icon: Icons.directions_walk, color: AppColors.accentBlue),
  FitnessStat(label: 'Calories', value: '342', unit: 'kcal', icon: Icons.local_fire_department, color: AppColors.accentAmber),
  FitnessStat(label: 'Distance', value: '4.3', unit: 'km', icon: Icons.straighten, color: AppColors.accentGreen),
  FitnessStat(label: 'BPM moy.', value: '78', unit: 'bpm', icon: Icons.favorite, color: AppColors.accentRed),
];

const kWeeklySteps = <double>[5800, 7200, 6500, 8400, 6900, 9100, 6247];
const kWeekDayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

const kPersonalRecords = [
  PersonalRecord(icon: Icons.directions_walk, color: AppColors.accentBlue, title: 'Plus longue marche', detail: '12.5 km · il y a 2 semaines'),
  PersonalRecord(icon: Icons.emoji_events, color: AppColors.accentAmber, title: 'Plus de pas en 1 jour', detail: '14 832 pas · il y a 1 mois'),
  PersonalRecord(icon: Icons.timer, color: AppColors.accentGreen, title: 'Course la plus rapide', detail: '5km en 28 min · il y a 3 jours'),
];

const kRecentSessions = [
  WorkoutSession(icon: Icons.directions_walk, type: 'Marche', detail: '35min · 3.2km · hier 18h12'),
  WorkoutSession(icon: Icons.directions_run, type: 'Course', detail: '28min · 5km · il y a 3 jours'),
  WorkoutSession(icon: Icons.directions_bike, type: 'Vélo', detail: '1h12 · 18km · il y a 5 jours'),
];
