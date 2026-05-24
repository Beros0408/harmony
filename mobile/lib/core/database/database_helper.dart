import 'package:sqflite_sqlcipher/sqflite.dart';

/// Singleton SQLCipher database helper.
/// Opens (or creates) `harmony.db` once; subsequent calls return the cached instance.
///
/// Passphrase: static for MVP — derive from device ID before production release.
class DatabaseHelper {
  DatabaseHelper._();

  static const _dbName = 'harmony.db';
  static const _dbVersion = 1;
  // ignore: constant_identifier_names
  static const _passphrase = 'harmony_mvp_2026';

  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() => openDatabase(
        _dbName,
        version: _dbVersion,
        password: _passphrase,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS blacklist_entries (
        id          TEXT PRIMARY KEY,
        phone_number TEXT NOT NULL UNIQUE,
        label       TEXT,
        reason      TEXT NOT NULL DEFAULT 'spam',
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_blacklist_phone ON blacklist_entries(phone_number)',
    );
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrations futures ajoutées ici.
  }

  /// Ferme la connexion (utile en tests uniquement).
  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
