import 'package:flutter/foundation.dart';
import 'package:harmony/core/database/database_helper.dart';
import 'package:harmony/features/call_filter/data/mock/security_mocks.dart';
import 'package:harmony/features/call_filter/data/models/blacklist_entry.dart';
import 'package:harmony/features/call_filter/data/native/call_filter_channel.dart';
import 'package:harmony/features/call_filter/data/repositories/i_blacklist_repository.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _tableName = 'blacklist_entries';

/// Numéros de départ insérés si la table est vide au premier lancement.
const _seedNumbers = [
  (phone: '+33123456789', label: 'Spam Téléphonie', reason: BlockReason.spam),
  (phone: '+33987654321', label: 'Démarcheur SFR', reason: BlockReason.telemarketing),
  (phone: '+33899123456', label: 'Numéro surtaxé', reason: BlockReason.spam),
];

/// Repository SQLCipher pour la blacklist d'appels.
/// Singleton — accès via [BlacklistRepository.instance].
///
/// Chaque mutation (add/update/delete/clear) appelle automatiquement [syncToNative]
/// pour mettre à jour le snapshot Kotlin [CallDecisionEngine] immédiatement.
class BlacklistRepository implements IBlacklistRepository {
  BlacklistRepository._();

  static final BlacklistRepository instance = BlacklistRepository._();

  /// Mode actif transmis au moteur natif lors de chaque sync.
  FilterModeType _mode = FilterModeType.normal;

  // ──────────────────────────────── Init ──────────────────────────────────

  /// Appeler une fois au démarrage (depuis main.dart) pour seed la DB si vide.
  Future<void> init() async {
    final db = await DatabaseHelper.db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    ) ?? 0;
    if (count == 0) {
      final now = DateTime.now();
      for (final seed in _seedNumbers) {
        await db.insert(
          _tableName,
          BlacklistEntry(
            id: _uuid.v4(),
            phoneNumber: seed.phone,
            label: seed.label,
            reason: seed.reason,
            createdAt: now,
            updatedAt: now,
          ).toMap(),
        );
      }
    }
  }

  // ──────────────────────────────── CRUD ──────────────────────────────────

  @override
  Future<List<BlacklistEntry>> getAll() async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(_tableName, orderBy: 'created_at DESC');
    return rows.map(BlacklistEntry.fromMap).toList();
  }

  @override
  Future<BlacklistEntry?> getById(String id) async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : BlacklistEntry.fromMap(rows.first);
  }

  @override
  Future<BlacklistEntry?> getByNumber(String phoneNumber) async {
    final db = await DatabaseHelper.db;
    final normalized = normalizePhoneNumber(phoneNumber);
    final rows = await db.query(
      _tableName,
      where: 'phone_number = ?',
      whereArgs: [normalized],
    );
    return rows.isEmpty ? null : BlacklistEntry.fromMap(rows.first);
  }

  @override
  Future<void> add(BlacklistEntry entry) async {
    final db = await DatabaseHelper.db;
    await db.insert(_tableName, entry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await syncToNative();
  }

  @override
  Future<void> update(BlacklistEntry entry) async {
    final db = await DatabaseHelper.db;
    final updated = entry.copyWith(updatedAt: DateTime.now());
    await db.update(_tableName, updated.toMap(), where: 'id = ?', whereArgs: [updated.id]);
    await syncToNative();
  }

  @override
  Future<void> delete(String id) async {
    final db = await DatabaseHelper.db;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    await syncToNative();
  }

  @override
  Future<void> clear() async {
    final db = await DatabaseHelper.db;
    await db.delete(_tableName);
    await syncToNative();
  }

  // ──────────────────────────────── Recherche ──────────────────────────────

  @override
  Future<List<BlacklistEntry>> search(String query) async {
    if (query.isEmpty) return getAll();
    final db = await DatabaseHelper.db;
    final q = '%$query%';
    final rows = await db.query(
      _tableName,
      where: 'phone_number LIKE ? OR label LIKE ?',
      whereArgs: [q, q],
      orderBy: 'created_at DESC',
    );
    return rows.map(BlacklistEntry.fromMap).toList();
  }

  // ──────────────────────────────── Mode ───────────────────────────────────

  /// Change le mode actif et resynchronise vers le natif.
  Future<void> setMode(FilterModeType mode) async {
    if (_mode == mode) return;
    _mode = mode;
    await syncToNative();
  }

  FilterModeType get currentMode => _mode;

  // ──────────────────────────────── Sync natif ─────────────────────────────

  /// Pousse la blacklist + mode actif vers [CallDecisionEngine] Kotlin.
  /// Appelé automatiquement après chaque mutation.
  @override
  Future<void> syncToNative() async {
    final entries = await getAll();
    final blacklistNums = entries.map((e) => e.phoneNumber).toList();

    final rules = <CallRule>[
      for (final n in blacklistNums)
        CallRule(type: CallRuleType.blacklist, phoneNumber: n),
      CallRule(type: CallRuleType.mode, value: _modeString(_mode)),
    ];
    await CallFilterChannel.syncRules(rules);
    debugPrint(
      '[BlacklistRepository] syncToNative — '
      '${blacklistNums.length} blacklist, mode=${_modeString(_mode)}',
    );
  }

  // ──────────────────────────────── Validation ─────────────────────────────

  /// Retourne true si le numéro est utilisable après normalisation.
  bool isValidPhoneNumber(String input) {
    final n = normalizePhoneNumber(input);
    if (n.isEmpty) return false;
    // E.164 minimal : + suivi d'au moins 7 chiffres, ou 8+ chiffres locaux
    final e164 = RegExp(r'^\+\d{7,15}$');
    final local = RegExp(r'^\d{8,15}$');
    return e164.hasMatch(n) || local.hasMatch(n);
  }

  /// Normalise un numéro en format E.164 quand possible.
  /// 06/07/09XXXXXXXX → +33XXXXXXXXX
  /// 0033XXXXXXXXX → +33XXXXXXXXX
  /// Espaces/tirets/points supprimés dans tous les cas.
  String normalizePhoneNumber(String input) {
    var n = input.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');
    if (n.startsWith('0033')) n = '+33${n.substring(4)}';
    if (n.startsWith('06') || n.startsWith('07') || n.startsWith('09')) {
      n = '+33${n.substring(1)}';
    }
    return n;
  }

  // ──────────────────────────────── Helper ─────────────────────────────────

  static String _modeString(FilterModeType mode) => switch (mode) {
        FilterModeType.normal => 'normal',
        FilterModeType.focus => 'focus',
        FilterModeType.night => 'night',
      };
}
