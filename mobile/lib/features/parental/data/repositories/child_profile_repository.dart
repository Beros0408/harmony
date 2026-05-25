import 'package:flutter/material.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/child_profile.dart';
import 'i_child_profile_repository.dart';

// Données seed Sprint 3 — Lucas 12 ans (bleu) + Emma 9 ans (violet)
const _defaultChildren = [
  ChildProfile(
    id: 'child-lucas-001',
    name: 'Lucas',
    age: 12,
    avatarColor: Color(0xFF4A90D9),
  ),
  ChildProfile(
    id: 'child-emma-002',
    name: 'Emma',
    age: 9,
    avatarColor: Color(0xFF9B59B6),
  ),
];

class ChildProfileRepository implements IChildProfileRepository {
  ChildProfileRepository._();

  static final ChildProfileRepository instance = ChildProfileRepository._();

  static const _table = 'child_profiles';

  Future<void> init() async {
    final db = await DatabaseHelper.db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_table'),
    );
    if (count == 0) {
      await seed(_defaultChildren);
    }
  }

  @override
  Future<List<ChildProfile>> getAll() async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(_table, orderBy: 'name ASC');
    return rows.map(ChildProfile.fromMap).toList();
  }

  @override
  Future<ChildProfile?> getById(String id) async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : ChildProfile.fromMap(rows.first);
  }

  @override
  Future<void> add(ChildProfile profile) async {
    final db = await DatabaseHelper.db;
    await db.insert(_table, profile.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> update(ChildProfile profile) async {
    final db = await DatabaseHelper.db;
    await db.update(_table, profile.toMap(), where: 'id = ?', whereArgs: [profile.id]);
  }

  @override
  Future<void> delete(String id) async {
    final db = await DatabaseHelper.db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> seed(List<ChildProfile> profiles) async {
    final db = await DatabaseHelper.db;
    final batch = db.batch();
    for (final p in profiles) {
      batch.insert(_table, p.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }
}
