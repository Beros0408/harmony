import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum SecurityScoreLevel { good, warning, danger }

class SecurityScore extends Equatable {
  final String childId;
  final int value;
  final DateTime lastUpdate;

  const SecurityScore({
    required this.childId,
    required this.value,
    required this.lastUpdate,
  });

  SecurityScoreLevel get level {
    if (value >= 70) return SecurityScoreLevel.good;
    if (value >= 40) return SecurityScoreLevel.warning;
    return SecurityScoreLevel.danger;
  }

  Color get color => switch (level) {
        SecurityScoreLevel.good => AppColors.accentGreen,
        SecurityScoreLevel.warning => AppColors.accentAmber,
        SecurityScoreLevel.danger => AppColors.accentRed,
      };

  Map<String, dynamic> toMap() => {
        'child_id': childId,
        'value': value,
        'last_update': lastUpdate.millisecondsSinceEpoch,
      };

  factory SecurityScore.fromMap(Map<String, dynamic> map) => SecurityScore(
        childId: map['child_id'] as String,
        value: map['value'] as int,
        lastUpdate: DateTime.fromMillisecondsSinceEpoch(map['last_update'] as int),
      );

  @override
  List<Object?> get props => [childId, value, lastUpdate];
}
