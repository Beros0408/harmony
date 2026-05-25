import 'package:flutter/material.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/safe_zone.dart';
import 'i_safe_zone_repository.dart';

// Zones seed — Maison (Paris 1er) + École + Stade
const _defaultZones = [
  SafeZone(
    id: 'zone-home-001',
    name: 'Maison',
    latitude: 48.8534,
    longitude: 2.3488,
    radiusMeters: 250,
    color: Color(0xFF27AE60),
    icon: SafeZoneIcon.home,
    activeDays: [],
    childIds: ['child-lucas-001', 'child-emma-002'],
  ),
  SafeZone(
    id: 'zone-school-002',
    name: 'École Jules Ferry',
    latitude: 48.8560,
    longitude: 2.3510,
    radiusMeters: 100,
    color: Color(0xFF2980B9),
    icon: SafeZoneIcon.school,
    activeDays: [1, 2, 3, 4, 5],
    startTime: TimeOfDay(hour: 8, minute: 0),
    endTime: TimeOfDay(hour: 17, minute: 0),
    childIds: ['child-lucas-001', 'child-emma-002'],
  ),
  SafeZone(
    id: 'zone-stadium-003',
    name: 'Stade municipal',
    latitude: 48.8500,
    longitude: 2.3450,
    radiusMeters: 150,
    color: Color(0xFFE67E22),
    icon: SafeZoneIcon.sport,
    activeDays: [3, 6],
    startTime: TimeOfDay(hour: 13, minute: 0),
    endTime: TimeOfDay(hour: 19, minute: 0),
    childIds: ['child-lucas-001', 'child-emma-002'],
  ),
];

class SafeZoneRepository implements ISafeZoneRepository {
  SafeZoneRepository._();

  static final SafeZoneRepository instance = SafeZoneRepository._();

  static const _table = 'safe_zones';

  Future<void> init() async {
    final db = await DatabaseHelper.db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_table'),
    );
    if (count == 0) {
      await seed(_defaultZones);
    }
  }

  @override
  Future<List<SafeZone>> getAll() async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(_table, orderBy: 'name ASC');
    return rows.map(SafeZone.fromMap).toList();
  }

  @override
  Future<SafeZone?> getById(String id) async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : SafeZone.fromMap(rows.first);
  }

  @override
  Future<List<SafeZone>> getActiveZonesFor(String childId, DateTime at) async {
    final all = await getAll();
    return all.where((z) => z.childIds.contains(childId) && z.isActiveAt(at)).toList();
  }

  @override
  Future<void> add(SafeZone zone) async {
    final db = await DatabaseHelper.db;
    await db.insert(_table, zone.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> update(SafeZone zone) async {
    final db = await DatabaseHelper.db;
    await db.update(_table, zone.toMap(), where: 'id = ?', whereArgs: [zone.id]);
  }

  @override
  Future<void> delete(String id) async {
    final db = await DatabaseHelper.db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> seed(List<SafeZone> zones) async {
    final db = await DatabaseHelper.db;
    final batch = db.batch();
    for (final z in zones) {
      batch.insert(_table, z.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }
}
