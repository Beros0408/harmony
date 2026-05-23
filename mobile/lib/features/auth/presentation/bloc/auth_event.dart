abstract class AuthEvent {
  const AuthEvent();
}

/// Vérifie si un PIN est déjà configuré au démarrage
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Configure un nouveau PIN (premier lancement)
class AuthPinSetupRequested extends AuthEvent {
  const AuthPinSetupRequested(this.pin);
  final String pin;
}

/// Soumet le PIN pour vérification
class AuthPinSubmitted extends AuthEvent {
  const AuthPinSubmitted(this.pin);
  final String pin;
}

/// Déclenche l'authentification biométrique
class AuthBiometricRequested extends AuthEvent {
  const AuthBiometricRequested();
}

/// Active ou désactive la biométrie après configuration du PIN
class AuthBiometricToggled extends AuthEvent {
  const AuthBiometricToggled({required this.enabled});
  final bool enabled;
}

/// Réinitialise la session (ne supprime pas le PIN)
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
