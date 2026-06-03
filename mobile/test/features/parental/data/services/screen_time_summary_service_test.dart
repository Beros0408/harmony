import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/parental/data/services/screen_time_summary_service.dart';

// ─── Stubs ────────────────────────────────────────────────────────────────────

class _StubSummaryService extends ScreenTimeSummaryService {
  final ScreenTimeSummary Function(String childId, DateTime? date) _handler;

  _StubSummaryService(this._handler);

  @override
  Future<ScreenTimeSummary> fetchSummary(String childId, {DateTime? date}) async =>
      _handler(childId, date);
}

class _NetworkErrorSummaryService extends ScreenTimeSummaryService {
  @override
  Future<ScreenTimeSummary> fetchSummary(String childId, {DateTime? date}) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/screen-time/usage/$childId/summary'),
      type: DioExceptionType.connectionError,
    );
  }
}

// ─── Données de test ──────────────────────────────────────────────────────────

const _childId = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';

ScreenTimeSummary _fakeSummary() => ScreenTimeSummary(
      childId: _childId,
      usageDate: '2026-06-03',
      totalSeconds: 6300,
      topApps: const [
        AppUsageEntry(
          packageName: 'com.instagram.android',
          appLabel: 'Instagram',
          category: 'social',
          durationSeconds: 3600,
        ),
        AppUsageEntry(
          packageName: 'com.google.android.youtube',
          appLabel: 'YouTube',
          category: 'entertainment',
          durationSeconds: 1800,
        ),
        AppUsageEntry(
          packageName: 'com.tiktok.android',
          appLabel: 'TikTok',
          category: 'social',
          durationSeconds: 900,
        ),
      ],
      totalByCategory: {'social': 4500, 'entertainment': 1800},
    );

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('ScreenTimeSummaryService', () {
    test('instance est un singleton', () {
      expect(
        identical(
          ScreenTimeSummaryService.instance,
          ScreenTimeSummaryService.instance,
        ),
        isTrue,
      );
    });

    test('fetchSummary retourne un résumé valide', () async {
      final svc = _StubSummaryService((id, _) => _fakeSummary());
      final summary = await svc.fetchSummary(_childId);

      expect(summary.childId, equals(_childId));
      expect(summary.totalSeconds, equals(6300));
      expect(summary.topApps, hasLength(3));
      expect(summary.topApps.first.packageName, equals('com.instagram.android'));
      expect(summary.totalByCategory['social'], equals(4500));
      expect(summary.totalByCategory['entertainment'], equals(1800));
    });

    test('top_apps est déjà trié par durée décroissante (vient du backend)', () async {
      final svc = _StubSummaryService((id, _) => _fakeSummary());
      final summary = await svc.fetchSummary(_childId);

      final durations = summary.topApps.map((a) => a.durationSeconds).toList();
      expect(durations, equals([...durations]..sort((a, b) => b.compareTo(a))));
    });

    test('fetchSummary transmet le child_id exact au handler', () async {
      String? receivedId;
      final svc = _StubSummaryService((id, _) {
        receivedId = id;
        return _fakeSummary();
      });
      await svc.fetchSummary('specific-child-uuid');
      expect(receivedId, equals('specific-child-uuid'));
    });

    test('fetchSummary transmet la date optionnelle au handler', () async {
      DateTime? receivedDate;
      final svc = _StubSummaryService((id, date) {
        receivedDate = date;
        return _fakeSummary();
      });
      final target = DateTime(2026, 6, 1);
      await svc.fetchSummary(_childId, date: target);
      expect(receivedDate, equals(target));
    });

    test('fetchSummary lance DioException sur erreur réseau', () {
      final svc = _NetworkErrorSummaryService();
      expect(
        () => svc.fetchSummary(_childId),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('ScreenTimeSummary.fromJson', () {
    test('désérialise correctement un JSON complet', () {
      final json = {
        'child_id': _childId,
        'usage_date': '2026-06-03',
        'total_seconds': 5400,
        'top_apps': [
          {
            'package_name': 'com.instagram.android',
            'app_label': 'Instagram',
            'category': 'social',
            'duration_seconds': 5400,
          },
        ],
        'total_by_category': {'social': 5400},
      };
      final summary = ScreenTimeSummary.fromJson(json);
      expect(summary.totalSeconds, equals(5400));
      expect(summary.topApps.first.appLabel, equals('Instagram'));
      expect(summary.totalByCategory['social'], equals(5400));
    });

    test('fromJson accepte app_label null', () {
      final json = {
        'child_id': _childId,
        'usage_date': '2026-06-03',
        'total_seconds': 120,
        'top_apps': [
          {
            'package_name': 'com.unknown.app',
            'app_label': null,
            'category': null,
            'duration_seconds': 120,
          },
        ],
        'total_by_category': {'other': 120},
      };
      final summary = ScreenTimeSummary.fromJson(json);
      expect(summary.topApps.first.appLabel, isNull);
      expect(summary.topApps.first.category, isNull);
    });
  });
}
