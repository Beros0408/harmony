abstract class IAuthRepository {
  Future<bool> isPinSet();
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> clearPin();
  Future<bool> isBiometricAvailable();
  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled({required bool enabled});
  Future<bool> authenticateWithBiometric();
}
