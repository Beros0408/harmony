import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ChildProfile extends Equatable {
  final String id;
  final String name;
  final int age;
  final Color avatarColor;
  final String? deviceId;

  const ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.avatarColor,
    this.deviceId,
  });

  ChildProfile copyWith({
    String? id,
    String? name,
    int? age,
    Color? avatarColor,
    String? deviceId,
  }) =>
      ChildProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age ?? this.age,
        avatarColor: avatarColor ?? this.avatarColor,
        deviceId: deviceId ?? this.deviceId,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'age': age,
        'avatar_color': avatarColor.toARGB32(),
        'device_id': deviceId,
      };

  factory ChildProfile.fromMap(Map<String, dynamic> map) => ChildProfile(
        id: map['id'] as String,
        name: map['name'] as String,
        age: map['age'] as int,
        avatarColor: Color(map['avatar_color'] as int),
        deviceId: map['device_id'] as String?,
      );

  @override
  List<Object?> get props => [id];
}
