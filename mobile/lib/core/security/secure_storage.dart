import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // flutter_secure_storage 10.x : EncryptedSharedPreferences est déprécié,
  // la migration vers les chiffrements internes est automatique.
  SecureStorageService() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  Future<String?> read({required String key}) =>
      _storage.read(key: key);

  Future<void> delete({required String key}) =>
      _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();

  Future<bool> containsKey({required String key}) =>
      _storage.containsKey(key: key);
}
