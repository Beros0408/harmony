import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persistance locale de l'app enfant (child_id après appairage).
/// Utilise FlutterSecureStorage pour chiffrer les données sensibles.
class KidsStorage {
  KidsStorage._();
  static final KidsStorage instance = KidsStorage._();

  static const _kChildId = 'harmony_kids_child_id';
  // Sprint S16 — Onboarding enfant
  static const _kOnboardingDone = 'harmony_kids_onboarding_done';

  final _storage = const FlutterSecureStorage();

  Future<void> saveChildId(String childId) =>
      _storage.write(key: _kChildId, value: childId);

  Future<String?> getChildId() => _storage.read(key: _kChildId);

  Future<void> clearChildId() => _storage.delete(key: _kChildId);

  Future<void> saveKidsOnboardingDone() =>
      _storage.write(key: _kOnboardingDone, value: 'true');

  Future<bool> getKidsOnboardingDone() async {
    final value = await _storage.read(key: _kOnboardingDone);
    return value == 'true';
  }

  Future<void> clearKidsOnboardingDone() =>
      _storage.delete(key: _kOnboardingDone);

  // ── Activité physique — pas du jour ──────────────────────────────────────
  static const _kStepOffset = 'harmony_kids_step_offset';
  static const _kStepDate   = 'harmony_kids_step_date';

  Future<void> saveStepOffset(int offset) =>
      _storage.write(key: _kStepOffset, value: offset.toString());

  Future<int?> getStepOffset() async {
    final value = await _storage.read(key: _kStepOffset);
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> saveStepDate(String date) =>
      _storage.write(key: _kStepDate, value: date);

  Future<String?> getStepDate() => _storage.read(key: _kStepDate);
}
