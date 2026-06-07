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
}
