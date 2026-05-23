import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum FitnessStatType { steps, calories, distance, heartRate }

enum PersonalRecordType { longestWalk, mostSteps, fastestRun }

enum SessionType { walk, run, bike }

class FitnessStat {
  final FitnessStatType type;
  final String value;
  final IconData icon;
  final Color color;
  const FitnessStat({required this.type, required this.value, required this.icon, required this.color});
}

class PersonalRecord {
  final PersonalRecordType type;
  final IconData icon;
  final Color color;
  const PersonalRecord({required this.type, required this.icon, required this.color});
}

class WorkoutSession {
  final SessionType type;
  final IconData icon;
  const WorkoutSession({required this.type, required this.icon});
}

const kTodayStats = [
  FitnessStat(type: FitnessStatType.steps, value: '6 247', icon: Icons.directions_walk, color: AppColors.accentBlue),
  FitnessStat(type: FitnessStatType.calories, value: '342', icon: Icons.local_fire_department, color: AppColors.accentAmber),
  FitnessStat(type: FitnessStatType.distance, value: '4.3', icon: Icons.straighten, color: AppColors.accentGreen),
  FitnessStat(type: FitnessStatType.heartRate, value: '78', icon: Icons.favorite, color: AppColors.accentRed),
];

const kWeeklySteps = <double>[5800, 7200, 6500, 8400, 6900, 9100, 6247];

const kPersonalRecords = [
  PersonalRecord(type: PersonalRecordType.longestWalk, icon: Icons.directions_walk, color: AppColors.accentBlue),
  PersonalRecord(type: PersonalRecordType.mostSteps, icon: Icons.emoji_events, color: AppColors.accentAmber),
  PersonalRecord(type: PersonalRecordType.fastestRun, icon: Icons.timer, color: AppColors.accentGreen),
];

const kRecentSessions = [
  WorkoutSession(type: SessionType.walk, icon: Icons.directions_walk),
  WorkoutSession(type: SessionType.run, icon: Icons.directions_run),
  WorkoutSession(type: SessionType.bike, icon: Icons.directions_bike),
];
