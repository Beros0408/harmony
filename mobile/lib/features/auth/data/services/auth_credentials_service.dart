import 'package:dio/dio.dart';
import '../../../../core/services/harmony_services.dart';
import '../../../../core/session/user_session.dart';

/// Appelle les endpoints d'authentification du backend FastAPI.
/// Stocke les tokens JWT et met à jour [UserSession] après succès.
class AuthCredentialsService {
  const AuthCredentialsService();
  static const AuthCredentialsService instance = AuthCredentialsService();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await HarmonyServices.dioClient.instance
        .post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: {'email': email, 'password': password},
    );
    await _handleAuthResponse(response.data!);
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await HarmonyServices.dioClient.instance
        .post<Map<String, dynamic>>(
      '/api/v1/auth/register',
      data: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': 'parent',
      },
    );
    await _handleAuthResponse(response.data!);
  }

  Future<void> logout() async {
    try {
      await HarmonyServices.dioClient.instance
          .post<void>('/api/v1/auth/logout');
    } on DioException {
      // Ignorer les erreurs réseau — on nettoie localement quoi qu'il arrive.
    }
    await HarmonyServices.tokenStorage.clearAll();
    UserSession.instance.clear();
  }

  Future<void> _handleAuthResponse(Map<String, dynamic> data) async {
    final tokens = data['tokens'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    final storage = HarmonyServices.tokenStorage;

    await storage.saveAccessToken(tokens['access_token'] as String);
    await storage.saveRefreshToken(tokens['refresh_token'] as String);
    await storage.saveUserId(user['id'] as String);
    await storage.saveUserEmail(user['email'] as String);
    await storage.saveUserFullName(user['full_name'] as String);

    UserSession.instance.update(
      parentId: user['id'] as String,
      email: user['email'] as String,
      fullName: user['full_name'] as String,
    );
  }
}
