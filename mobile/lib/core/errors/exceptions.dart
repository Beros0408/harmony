class ServerException implements Exception {
  const ServerException([this.message = 'Erreur serveur']);
  final String message;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'Pas de connexion réseau']);
  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Erreur de cache local']);
  final String message;
}

class AuthException implements Exception {
  const AuthException([this.message = 'Session expirée']);
  final String message;
}
