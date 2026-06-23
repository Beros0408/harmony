import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/child_profile.dart';
import 'i_child_profile_repository.dart';

class ChildProfileRepository implements IChildProfileRepository {
  ChildProfileRepository._();

  static final ChildProfileRepository instance = ChildProfileRepository._();

  static const _table = 'child_profiles';

  /// Initialise le schéma local. Plus de seed fictif depuis Sprint B2 :
  /// les vrais enfants sont chargés depuis Supabase via FamilyApiService.
  Future<void> init() async {
    // Appel suffisant pour s'assurer que la table existe (DatabaseHelper.db
    // crée le schéma lors de la première ouverture).
    await DatabaseHelper.db;
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
  Future<void> seed(List<ChildProfile> profiles) async {
    final db = await DatabaseHelper.db;
    final batch = db.batch();
    for (final p in profiles) {
      batch.insert(_table, p.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }
}
