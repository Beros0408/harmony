import 'secure_storage.dart';

// Clés de stockage pour les tokens JWT et le profil utilisateur
class _TokenKeys {
  static const String accessToken = 'harmony_access_token';
  static const String refreshToken = 'harmony_refresh_token';
  static const String userId = 'harmony_user_id';
  static const String userEmail = 'harmony_user_email';
  static const String userFullName = 'harmony_user_full_name';
}

abstract interface class ITokenStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveUserId(String id);
  Future<String?> getUserId();
  Future<void> saveUserEmail(String email);
  Future<String?> getUserEmail();
  Future<void> saveUserFullName(String name);
  Future<String?> getUserFullName();
  Future<void> clearAll();
}

/// Stockage sécurisé des tokens JWT et du profil utilisateur via flutter_secure_storage.
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
  Future<void> saveUserId(String id) =>
      _storage.write(key: _TokenKeys.userId, value: id);

  @override
  Future<String?> getUserId() =>
      _storage.read(key: _TokenKeys.userId);

  @override
  Future<void> saveUserEmail(String email) =>
      _storage.write(key: _TokenKeys.userEmail, value: email);

  @override
  Future<String?> getUserEmail() =>
      _storage.read(key: _TokenKeys.userEmail);

  @override
  Future<void> saveUserFullName(String name) =>
      _storage.write(key: _TokenKeys.userFullName, value: name);

  @override
  Future<String?> getUserFullName() =>
      _storage.read(key: _TokenKeys.userFullName);

  @override
  Future<void> clearAll() => _storage.deleteAll();
}
