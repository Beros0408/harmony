import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../../core/services/harmony_services.dart';

// ─── Modèles ──────────────────────────────────────────────────────────────────

class PrivacyDeleteResult {
  const PrivacyDeleteResult({
    required this.deleted,
    required this.childId,
    required this.tablesTouched,
  });

  final bool deleted;
  final String childId;
  final Map<String, int> tablesTouched;

  factory PrivacyDeleteResult.fromJson(Map<String, dynamic> j) =>
      PrivacyDeleteResult(
        deleted: j['deleted'] as bool,
        childId: j['child_id'] as String,
        tablesTouched: (j['tables_touched'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ),
      );
}

/// Résultat de l'écriture locale du fichier d'export.
class ExportFileResult {
  const ExportFileResult({required this.path, required this.isExternal});

  /// Chemin absolu du fichier écrit.
  final String path;

  /// true → stockage externe (visible dans le gestionnaire de fichiers Android).
  /// false → répertoire interne de l'application (non visible sans root).
  final bool isExternal;
}

// ─── Service ─────────────────────────────────────────────────────────────────

class PrivacyService {
  PrivacyService._();
  static final PrivacyService instance = PrivacyService._();

  /// RGPD — droit d'accès : récupère toutes les données de l'enfant.
  Future<Map<String, dynamic>> exportData(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<Map<String, dynamic>>('/api/v1/privacy/export/$childId');
    return response.data!;
  }

  /// RGPD — droit à l'effacement : supprime toutes les données de l'enfant.
  Future<PrivacyDeleteResult> deleteData(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .delete<Map<String, dynamic>>('/api/v1/privacy/data/$childId');
    return PrivacyDeleteResult.fromJson(response.data!);
  }

  /// Écrit le JSON d'export dans un fichier sur l'appareil.
  ///
  /// Priorité : stockage externe (accessible depuis le gestionnaire de fichiers
  /// Android — Android/data/…/files/) puis repli sur le répertoire interne de
  /// l'application (non visible sans explorateur de fichiers root).
  ///
  /// Nom du fichier : harmony_export_{prénom}_{AAAAMMJJ}.json
  Future<ExportFileResult> saveExportFile(
    String childName,
    Map<String, dynamic> data,
  ) async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    // Garde uniquement les caractères ASCII alphanumériques pour un nom sûr.
    final safeName = childName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final filename = 'harmony_export_${safeName}_$dateStr.json';

    Directory? dir;
    var isExternal = false;
    try {
      dir = await getExternalStorageDirectory();
      if (dir != null) isExternal = true;
    } catch (_) {}
    dir ??= await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return ExportFileResult(path: file.path, isExternal: isExternal);
  }
}
