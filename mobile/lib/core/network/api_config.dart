import 'dart:io';

import 'package:flutter/foundation.dart';

/// Configuration de l'URL de base du backend Harmony.
///
/// Priorité :
/// 1. Variable injectée au build via `--dart-define=API_BASE_URL=...`
///    (ex : URL Vercel en production, IP locale pour appareil physique)
/// 2. `http://10.0.2.2:8000` en mode debug sur émulateur Android
///    (10.0.2.2 est l'alias Android vers la machine hôte)
/// 3. `http://localhost:8000` pour tout autre contexte de développement
///    (simulateur iOS, web, desktop)
class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    // Permet de surcharger l'URL sans recompiler (CI, staging, prod).
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // Sur émulateur Android en debug, le PC hôte n'est pas "localhost"
    // mais l'alias réseau 10.0.2.2 fourni par l'AVD.
    if (kDebugMode && !kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://localhost:8000';
  }
}
