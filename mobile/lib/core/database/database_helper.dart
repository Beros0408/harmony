import 'package:sqflite_sqlcipher/sqflite.dart';

/// Singleton SQLCipher database helper.
/// Opens (or creates) `harmony.db` once; subsequent calls return the cached instance.
///
/// Passphrase: static for MVP — derive from device ID before production release.
class DatabaseHelper {
  DatabaseHelper._();

  static const _dbName = 'harmony.db';
  static const _dbVersion = 4;
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
    await _createBlacklistTable(db);
    await _createParentalTables(db);
    await _createAgendaTables(db);
    await _createFitnessTables(db);
    await _createMessageRulesTables(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createParentalTables(db);
    }
    if (oldVersion < 3) {
      await _createAgendaTables(db);
    }
    if (oldVersion < 4) {
      await _createFitnessTables(db);
      await _createMessageRulesTables(db);
    }
  }

  static Future<void> _createBlacklistTable(Database db) async {
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

  static Future<void> _createParentalTables(Database db) async {
    // Profils enfants
    await db.execute('''
      CREATE TABLE IF NOT EXISTS child_profiles (
        id           TEXT PRIMARY KEY,
        name         TEXT NOT NULL,
        age          INTEGER NOT NULL,
        avatar_color INTEGER NOT NULL,
        device_id    TEXT
      )
    ''');

    // Points de localisation (historique 30 jours)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS location_points (
        id           TEXT PRIMARY KEY,
        child_id     TEXT NOT NULL,
        latitude     REAL NOT NULL,
        longitude    REAL NOT NULL,
        accuracy     REAL NOT NULL,
        timestamp    INTEGER NOT NULL,
        battery_level INTEGER
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_location_child_ts ON location_points(child_id, timestamp)',
    );

    // Zones sécurisées
    await db.execute('''
      CREATE TABLE IF NOT EXISTS safe_zones (
        id            TEXT PRIMARY KEY,
        name          TEXT NOT NULL,
        latitude      REAL NOT NULL,
        longitude     REAL NOT NULL,
        radius_meters REAL NOT NULL,
        color         INTEGER NOT NULL,
        icon          INTEGER NOT NULL,
        active_days   TEXT NOT NULL DEFAULT '',
        start_hour    INTEGER,
        start_minute  INTEGER,
        end_hour      INTEGER,
        end_minute    INTEGER,
        child_ids     TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Évènements geofence (entrée/sortie de zone)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS geofence_events (
        id        TEXT PRIMARY KEY,
        child_id  TEXT NOT NULL,
        zone_id   TEXT NOT NULL,
        zone_name TEXT NOT NULL,
        type      INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        latitude  REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy  REAL NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_geofence_child_ts ON geofence_events(child_id, timestamp)',
    );

    // Alertes SOS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sos_alerts (
        id         TEXT PRIMARY KEY,
        child_id   TEXT NOT NULL,
        child_name TEXT NOT NULL,
        timestamp  INTEGER NOT NULL,
        latitude   REAL NOT NULL,
        longitude  REAL NOT NULL,
        accuracy   REAL NOT NULL,
        status     INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Scores de sécurité (1 ligne par enfant, upsert)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS security_scores (
        child_id    TEXT PRIMARY KEY,
        value       INTEGER NOT NULL,
        last_update INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _createAgendaTables(Database db) async {
    // Événements agenda
    await db.execute('''
      CREATE TABLE IF NOT EXISTS agenda_events (
        id                      TEXT PRIMARY KEY,
        title                   TEXT NOT NULL,
        description             TEXT NOT NULL DEFAULT '',
        category                INTEGER NOT NULL,
        start_date              INTEGER NOT NULL,
        end_date                INTEGER NOT NULL,
        location                TEXT,
        recurrence_rule         TEXT,
        reminder_minutes_before INTEGER NOT NULL DEFAULT 30,
        important               INTEGER NOT NULL DEFAULT 0,
        google_event_id         TEXT,
        family_member_ids       TEXT NOT NULL DEFAULT '',
        color                   INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_agenda_dates ON agenda_events(start_date, end_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_agenda_google ON agenda_events(google_event_id)',
    );

    // Tâches Eisenhower
    await db.execute('''
      CREATE TABLE IF NOT EXISTS agenda_tasks (
        id              TEXT PRIMARY KEY,
        title           TEXT NOT NULL,
        urgency         INTEGER NOT NULL,
        importance      INTEGER NOT NULL,
        deadline        INTEGER,
        completed       INTEGER NOT NULL DEFAULT 0,
        linked_event_id TEXT
      )
    ''');

    // Sync Google Calendar
    await db.execute('''
      CREATE TABLE IF NOT EXISTS google_calendar_sync (
        id              TEXT PRIMARY KEY,
        account_email   TEXT NOT NULL,
        last_sync_at    INTEGER,
        next_sync_token TEXT
      )
    ''');
  }

  static Future<void> _createFitnessTables(Database db) async {
    // Pas quotidiens (1 ligne par jour)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_steps (
        date         TEXT PRIMARY KEY,
        step_count   INTEGER NOT NULL DEFAULT 0,
        goal_steps   INTEGER NOT NULL DEFAULT 8000,
        created_at   INTEGER NOT NULL
      )
    ''');

    // Séances d'entraînement
    await db.execute('''
      CREATE TABLE IF NOT EXISTS workout_sessions (
        id              TEXT PRIMARY KEY,
        type            TEXT NOT NULL,
        start_time      INTEGER NOT NULL,
        end_time        INTEGER,
        steps_total     INTEGER NOT NULL DEFAULT 0,
        distance_meters REAL NOT NULL DEFAULT 0,
        avg_heart_rate  INTEGER
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_workout_start ON workout_sessions(start_time)',
    );
  }

  static Future<void> _createMessageRulesTables(Database db) async {
    // Règles de filtrage messages (persistance SQLCipher)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS message_rules (
        id                  TEXT PRIMARY KEY,
        type                TEXT NOT NULL,
        value               TEXT NOT NULL DEFAULT '',
        action              TEXT NOT NULL,
        sources             TEXT NOT NULL DEFAULT '[]',
        schedule_start_hour INTEGER,
        schedule_end_hour   INTEGER,
        is_active           INTEGER NOT NULL DEFAULT 1,
        created_at          INTEGER NOT NULL
      )
    ''');
  }

  /// Ferme la connexion (utile en tests uniquement).
  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
