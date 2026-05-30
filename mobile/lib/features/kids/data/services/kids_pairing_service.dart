import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import '../../../../core/services/harmony_services.dart';

class KidsPairingResult {
  const KidsPairingResult({
    required this.parentName,
    required this.childName,
    required this.childId,
  });

  final String parentName;
  final String childName;
  final String childId; // UUID du profil enfant dans Supabase (public.profiles)
}

/// Appelle POST /api/v1/pairing/redeem et retourne les infos de liaison.
class KidsPairingService {
  KidsPairingService();

  static final KidsPairingService instance = KidsPairingService();

  Future<KidsPairingResult> redeemCode(String code) async {
    final deviceLabel = await _deviceLabel();

    final response = await HarmonyServices.dioClient.instance
        .post<Map<String, dynamic>>(
      '/api/v1/pairing/redeem',
      data: {
        'code': code.trim(),
        'device_label': deviceLabel,
      },
    );

    final data = response.data!;
    return KidsPairingResult(
      parentName: data['parent_name'] as String,
      childName: data['child_name'] as String,
      childId: data['child_id'] as String,
    );
  }

  // Retourne marque + modèle de l'appareil pour le device_label.
  Future<String> _deviceLabel() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        return '${android.manufacturer} ${android.model}';
      } else if (Platform.isIOS) {
        final ios = await info.iosInfo;
        return ios.utsname.machine;
      }
    } catch (_) {
      // Silencieux : device_label est optionnel
    }
    return 'Unknown device';
  }
}
