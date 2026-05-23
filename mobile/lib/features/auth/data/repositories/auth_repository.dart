import 'package:local_auth/local_auth.dart';
import '../../../../core/security/secure_storage.dart';
import '../../domain/repositories/i_auth_repository.dart';

// Clés de stockage sécurisé pour l'authentification locale
class _Keys {
  static const String pin = 'harmony_auth_pin';
  static const String biometricEnabled = 'harmony_biometric_enabled';
}

class AuthRepository implements IAuthRepository {
  AuthRepository({
    required SecureStorageService storage,
    LocalAuthentication? localAuth,
  })  : _storage = storage,
        _localAuth = localAuth ?? LocalAuthentication();

  final SecureStorageService _storage;
  final LocalAuthentication _localAuth;

  @override
  Future<bool> isPinSet() => _storage.containsKey(key: _Keys.pin);

  @override
  Future<void> setPin(String pin) => _storage.write(key: _Keys.pin, value: pin);

  @override
  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _Keys.pin);
    return stored != null && stored == pin;
  }

  @override
  Future<void> clearPin() => _storage.delete(key: _Keys.pin);

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _Keys.biometricEnabled);
    return value == 'true';
  }

  @override
  Future<void> setBiometricEnabled({required bool enabled}) =>
      _storage.write(key: _Keys.biometricEnabled, value: enabled.toString());

  @override
  Future<bool> authenticateWithBiometric() async {
    try {
      // local_auth 3.x : stickyAuth renommé persistAcrossBackgrounding
      return await _localAuth.authenticate(
        localizedReason: 'Déverrouillez Harmony pour continuer',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
