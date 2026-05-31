import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Pont Dart ↔ MethodChannel vers [HarmonyDnsVpnService] (Android).
/// Channel : "harmony/content_filter"
///
/// Utilisé par [CommandPollingService] pour démarrer/arrêter le VPN DNS
/// en fonction de l'état reçu du backend, et par [KidsAdminScreen] pour
/// afficher l'état courant à l'enfant (transparence légale).
class ContentFilterService {
  ContentFilterService._();
  static final ContentFilterService instance = ContentFilterService._();

  static const _channel = MethodChannel('harmony/content_filter');

  /// Indique si le tunnel VPN DNS est actuellement actif.
  Future<bool> isFiltering() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isFiltering') ?? false;
    } catch (e) {
      debugPrint('[ContentFilterService] isFiltering error: $e');
      return false;
    }
  }

  /// Démarre le VPN DNS filtrant.
  ///
  /// Retourne :
  ///   "started"             — tunnel démarré avec succès.
  ///   "permission_required" — boîte de dialogue permission VPN affichée ;
  ///                           l'utilisateur doit accepter et l'app relancera
  ///                           startFiltering() au prochain cycle (15 s).
  ///   "error"               — erreur inattendue (loguée côté Kotlin).
  ///   "unsupported"         — plateforme non Android.
  Future<String> startFiltering() async {
    if (!Platform.isAndroid) return 'unsupported';
    try {
      return await _channel.invokeMethod<String>('startFiltering') ?? 'unknown';
    } catch (e) {
      debugPrint('[ContentFilterService] startFiltering error: $e');
      return 'error';
    }
  }

  /// Arrête le VPN DNS filtrant.
  Future<void> stopFiltering() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('stopFiltering');
    } catch (e) {
      debugPrint('[ContentFilterService] stopFiltering error: $e');
    }
  }
}
