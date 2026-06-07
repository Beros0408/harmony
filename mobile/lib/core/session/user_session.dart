import 'package:flutter/foundation.dart';
import '../security/token_storage.dart';

/// Session serveur du parent connecté.
/// Singleton ChangeNotifier — utilisé comme [refreshListenable] par GoRouter
/// pour redéclencher le redirect quand la session change.
class UserSession extends ChangeNotifier {
  UserSession._();
  static final UserSession instance = UserSession._();

  String? _parentId;
  String? _email;
  String? _fullName;
  bool _onboardingDone = false;

  String? get parentId => _parentId;
  String? get email => _email;
  String? get fullName => _fullName;
  bool get onboardingDone => _onboardingDone;

  bool get isAuthenticated => _parentId != null;

  /// Met à jour la session après connexion ou inscription réussie.
  void update({
    required String parentId,
    required String email,
    required String fullName,
  }) {
    _parentId = parentId;
    _email = email;
    _fullName = fullName;
    notifyListeners();
  }

  /// Marque l'onboarding comme terminé et notifie le router.
  void completeOnboarding() {
    _onboardingDone = true;
    notifyListeners();
  }

  /// Efface la session (déconnexion).
  void clear() {
    _parentId = null;
    _email = null;
    _fullName = null;
    _onboardingDone = false;
    notifyListeners();
  }

  /// Restaure la session depuis le stockage sécurisé au démarrage.
  /// Lecture locale uniquement — pas d'appel réseau.
  /// Doit être appelé AVANT [runApp] ; notifyListeners n'est pas nécessaire ici.
  Future<void> tryRestoreFromStorage(ITokenStorage storage) async {
    final userId = await storage.getUserId();
    if (userId == null) return;
    _parentId = userId;
    _email = await storage.getUserEmail() ?? '';
    _fullName = await storage.getUserFullName() ?? '';
    _onboardingDone = await storage.getOnboardingDone();
  }
}
