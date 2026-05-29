import '../network/api_config.dart';
import '../network/dio_client.dart';
import '../security/token_storage.dart';

/// Point d'accès centralisé aux services singleton de l'application.
/// Initialiser avec [HarmonyServices.init] avant [runApp].
class HarmonyServices {
  HarmonyServices._();

  static late final ITokenStorage tokenStorage;
  static late final DioClient dioClient;

  static void init() {
    tokenStorage = SecureTokenStorage();
    // ApiConfig.baseUrl choisit l'URL adaptée à la plateforme (émulateur, simulateur, prod).
    dioClient = DioClient(
      baseUrl: ApiConfig.baseUrl,
      tokenStorage: tokenStorage,
    );
  }
}
