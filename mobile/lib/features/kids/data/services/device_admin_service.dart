import 'dart:io';

import 'package:flutter/services.dart';

/// Pont Flutter → MethodChannel "harmony/device_admin".
/// Android uniquement : les méthodes renvoient des valeurs neutres sur les autres plateformes.
class DeviceAdminService {
  DeviceAdminService();

  static final DeviceAdminService instance = DeviceAdminService();

  static const _channel = MethodChannel('harmony/device_admin');

  /// Vérifie si Harmony Kids est actuellement administrateur d'appareil.
  Future<bool> isAdminActive() async {
    if (!Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('isAdminActive') ?? false;
  }

  /// Lance l'écran système Android pour demander les droits d'administrateur.
  /// Fire-and-forget : rappeler [isAdminActive] après retour dans l'app.
  Future<void> requestAdmin() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('requestAdmin');
  }

  /// Verrouille l'écran immédiatement.
  /// Lance une [PlatformException] si le mode admin n'est pas actif.
  Future<void> lockNow() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('lockNow');
  }
}
