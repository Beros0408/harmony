import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum SafeZoneIcon { home, school, sport, other }

class SafeZone extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final Color color;
  final SafeZoneIcon icon;
  /// Jours actifs : liste de 0 (lundi) à 6 (dimanche), vide = tous les jours
  final List<int> activeDays;
  /// Plage horaire : null = toute la journée
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final List<String> childIds;

  const SafeZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.color,
    required this.icon,
    required this.activeDays,
    required this.childIds,
    this.startTime,
    this.endTime,
  });

  bool isActiveAt(DateTime dateTime) {
    if (activeDays.isNotEmpty && !activeDays.contains(dateTime.weekday % 7)) {
      return false;
    }
    if (startTime != null && endTime != null) {
      final nowMinutes = dateTime.hour * 60 + dateTime.minute;
      final startMinutes = startTime!.hour * 60 + startTime!.minute;
      final endMinutes = endTime!.hour * 60 + endTime!.minute;
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    }
    return true;
  }

  SafeZone copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    Color? color,
    SafeZoneIcon? icon,
    List<int>? activeDays,
    List<String>? childIds,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) =>
      SafeZone(
        id: id ?? this.id,
        name: name ?? this.name,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        radiusMeters: radiusMeters ?? this.radiusMeters,
        color: color ?? this.color,
        icon: icon ?? this.icon,
        activeDays: activeDays ?? this.activeDays,
        childIds: childIds ?? this.childIds,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radius_meters': radiusMeters,
        'color': color.toARGB32(),
        'icon': icon.index,
        'active_days': activeDays.join(','),
        'start_hour': startTime?.hour,
        'start_minute': startTime?.minute,
        'end_hour': endTime?.hour,
        'end_minute': endTime?.minute,
        'child_ids': childIds.join(','),
      };

  factory SafeZone.fromMap(Map<String, dynamic> map) {
    final daysStr = map['active_days'] as String? ?? '';
    final childIdsStr = map['child_ids'] as String? ?? '';
    final startHour = map['start_hour'] as int?;
    final startMin = map['start_minute'] as int?;
    final endHour = map['end_hour'] as int?;
    final endMin = map['end_minute'] as int?;

    return SafeZone(
      id: map['id'] as String,
      name: map['name'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      radiusMeters: (map['radius_meters'] as num).toDouble(),
      color: Color(map['color'] as int),
      icon: SafeZoneIcon.values[map['icon'] as int],
      activeDays: daysStr.isEmpty ? [] : daysStr.split(',').map(int.parse).toList(),
      childIds: childIdsStr.isEmpty ? [] : childIdsStr.split(',').toList(),
      startTime: startHour != null && startMin != null ? TimeOfDay(hour: startHour, minute: startMin) : null,
      endTime: endHour != null && endMin != null ? TimeOfDay(hour: endHour, minute: endMin) : null,
    );
  }

  @override
  List<Object?> get props => [id, name, latitude, longitude, radiusMeters, color.toARGB32(), icon, activeDays, childIds];
}
