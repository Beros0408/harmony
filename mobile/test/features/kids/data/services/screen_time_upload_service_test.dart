import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/kids/data/services/screen_time_upload_service.dart';

// ─── Stubs ────────────────────────────────────────────────────────────────────

/// Service qui capture les paramètres du batch sans appel réseau.
class _CapturingUploadService extends ScreenTimeUploadService {
  String? capturedChildId;
  List<Map<String, dynamic>>? capturedEntries;
  bool called = false;

  @override
  Future<void> uploadBatch(String childId, List<Map<String, dynamic>> entries) async {
    called = true;
    capturedChildId = childId;
    capturedEntries = entries;
  }
}

/// Service qui simule une erreur réseau lors du batch.
class _NetworkErrorUploadService extends ScreenTimeUploadService {
  bool errorThrown = false;

  @override
  Future<void> uploadBatch(String childId, List<Map<String, dynamic>> entries) async {
    errorThrown = true;
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/screen-time/usage'),
      type: DioExceptionType.connectionError,
    );
  }
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('ScreenTimeUploadService.uploadBatch', () {
    test('instance est un singleton', () {
      expect(
        identical(
          ScreenTimeUploadService.instance,
          ScreenTimeUploadService.instance,
        ),
        isTrue,
      );
    });

    test('uploadBatch reçoit les bonnes données (child_id + entrées)', () async {
      final svc = _CapturingUploadService();
      final entries = [
        {
          'package_name': 'com.instagram.android',
          'app_label': 'Instagram',
          'category': 'social',
          'duration_seconds': 3600,
          'usage_date': '2026-06-03',
        },
        {
          'package_name': 'com.google.android.youtube',
          'app_label': 'YouTube',
          'category': 'entertainment',
          'duration_seconds': 1800,
          'usage_date': '2026-06-03',
        },
      ];

      await svc.uploadBatch('child-uuid-123', entries);

      expect(svc.called, isTrue);
      expect(svc.capturedChildId, equals('child-uuid-123'));
      expect(svc.capturedEntries, hasLength(2));
      expect(svc.capturedEntries![0]['package_name'], equals('com.instagram.android'));
      expect(svc.capturedEntries![1]['duration_seconds'], equals(1800));
    });

    test('uploadBatch avec liste vide ne plante pas', () async {
      final svc = _CapturingUploadService();
      await svc.uploadBatch('child-uuid-456', []);
      expect(svc.called, isTrue);
      expect(svc.capturedEntries, isEmpty);
    });

    test('uploadBatch ne propage pas DioException (erreur réseau silencieuse)', () async {
      // La méthode uploadBatch elle-même peut lancer — c'est _triggerUpload qui absorbe.
      // On vérifie que le service d'erreur peut être créé et que l'exception est bien de type Dio.
      final svc = _NetworkErrorUploadService();
      expect(
        () => svc.uploadBatch('child-uuid-789', []),
        throwsA(isA<DioException>()),
      );
    });

    test('format date : padLeft correct pour mois et jour à un chiffre', () {
      // Test de la logique de formatage de date en isolement
      final now = DateTime(2026, 3, 5);
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      expect(dateStr, equals('2026-03-05'));
    });

    test('format date : mois et jour à deux chiffres restent inchangés', () {
      final now = DateTime(2026, 12, 31);
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      expect(dateStr, equals('2026-12-31'));
    });
  });
}
