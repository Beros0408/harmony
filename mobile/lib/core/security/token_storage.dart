import 'secure_storage.dart';

// Clés de stockage pour les tokens JWT
class _TokenKeys {
  static const String accessToken = 'harmony_access_token';
  static const String refreshToken = 'harmony_refresh_token';
}

abstract interface class ITokenStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearAll();
}

/// Stockage sécurisé des tokens JWT via flutter_secure_storage.
/// Android : AES-256 via EncryptedSharedPreferences.
/// iOS : Keychain avec protection kSecAttrAccessibleAfterFirstUnlock.
class SecureTokenStorage implements ITokenStorage {
  SecureTokenStorage({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService();

  final SecureStorageService _storage;

  @override
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _TokenKeys.accessToken, value: token);

  @override
  Future<String?> getAccessToken() =>
      _storage.read(key: _TokenKeys.accessToken);

  @override
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _TokenKeys.refreshToken, value: token);

  @override
  Future<String?> getRefreshToken() =>
      _storage.read(key: _TokenKeys.refreshToken);

  @override
  Future<void> clearAll() => _storage.deleteAll();
}
