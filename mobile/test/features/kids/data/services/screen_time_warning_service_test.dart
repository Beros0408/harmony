import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/kids/data/services/screen_time_limits_fetch_service.dart';
import 'package:harmony/features/kids/data/services/screen_time_warning_service.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

const _today = '2026-06-04';
const _yesterday = '2026-06-03';

KidsScreenTimeStatus _status({
  required String scope,
  required int remainingSeconds,
  required bool exceeded,
  String? packageName,
  int limitSeconds = 3600,
}) =>
    KidsScreenTimeStatus(
      scope: scope,
      limitSeconds: limitSeconds,
      usedSeconds: limitSeconds - remainingSeconds,
      remainingSeconds: remainingSeconds,
      exceeded: exceeded,
      packageName: packageName,
    );

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ─── computeWarnings — règles de base ─────────────────────────────────────

  group('computeWarnings — aucun avertissement', () {
    test('liste vide → aucun résultat', () {
      final result =
          ScreenTimeWarningService.computeWarnings([], _today, {});
      expect(result, isEmpty);
    });

    test('remaining > tous les seuils → aucun résultat', () {
      final result = ScreenTimeWarningService.computeWarnings(
        [_status(scope: 'global', remainingSeconds: 700, exceeded: false)],
        _today,
        {},
      );
      expect(result, isEmpty);
    });

    test('remaining = seuil exact (600) → pas sous le seuil, pas de notif', () {
      final result = ScreenTimeWarningService.computeWarnings(
        [_status(scope: 'global', remainingSeconds: 600, exceeded: false)],
        _today,
        {},
      );
      expect(result, isEmpty);
    });

    test('limite déjà dépassée (exceeded = true) → pas de notif', () {
      final result = ScreenTimeWarningService.computeWarnings(
        [_status(scope: 'global', remainingSeconds: 0, exceeded: true)],
        _today,
        {},
      );
      expect(result, isEmpty);
    });

    test(
        'limite par app dépassée (exceeded = true) → pas de notif même si '
        'remaining = 0', () {
      final result = ScreenTimeWarningService.computeWarnings(
        [
          _status(
            scope: 'app',
            remainingSeconds: 0,
            exceeded: true,
            packageName: 'com.example.game',
          ),
        ],
        _today,
        {},
      );
      expect(result, isEmpty);
    });
  });

  group('computeWarnings — seuils franchis', () {
    test('remaining < 600 → avertissement 600s envoyé', () {
      final result = ScreenTimeWarningService.computeWarnings(
        [_status(scope: 'global', remainingSeconds: 599, exceeded: false)],
        _today,
        {},
      );
      expect(result, hasLength(1));
      expect(result.first.thresholdSeconds, equals(600));
      expect(result.first.scope, equals('global'));
    });

    test('remaining < 300 → avertissements 600s ET 300s', () {
      final result = ScreenTimeWarningService.computeWarnings(
        [_status(scope: 'global', remainingSeconds: 299, exceeded: false)],
        _today,
        {},
      );
      expect(result, hasLength(2));
      final thresholds =
          result.map((w) => w.thresholdSeconds).toSet();
      expect(thresholds, containsAll([600, 300]));
    });

    test('remaining < 60 → avertissements 600s, 300s ET 60s', () {
      final result = ScreenTimeWarningService.computeWarnings(
        [_status(scope: 'global', remainingSeconds: 59, exceeded: false)],
        _today,
        {},
      );
      expect(result, hasLength(3));
      final thresholds =
          result.map((w) => w.thresholdSeconds).toSet();
      expect(thresholds, containsAll([600, 300, 60]));
    });

    test('limite par app sous 300s → notif avec packageName', () {
      final result = ScreenTimeWarningService.computeWarnings(
        [
          _status(
            scope: 'app',
            remainingSeconds: 200,
            exceeded: false,
            packageName: 'com.instagram.android',
          ),
        ],
        _today,
        {},
      );
      expect(result, isNotEmpty);
      expect(result.first.packageName, equals('com.instagram.android'));
    });
  });

  // ─── Anti-spam ─────────────────────────────────────────────────────────────

  group('anti-spam', () {
    test('seuil déjà notifié aujourd\'hui → aucun résultat', () {
      const notified = {
        'global||600': _today,
        'global||300': _today,
        'global||60': _today,
      };
      final result = ScreenTimeWarningService.computeWarnings(
        [_status(scope: 'global', remainingSeconds: 59, exceeded: false)],
        _today,
        notified,
      );
      expect(result, isEmpty);
    });

    test(
        'seul le seuil 300s est déjà notifié → '
        'les deux autres (600 et 60) sont envoyés', () {
      final notified = <String, String>{'global||300': _today};
      final result = ScreenTimeWarningService.computeWarnings(
        [_status(scope: 'global', remainingSeconds: 59, exceeded: false)],
        _today,
        notified,
      );
      expect(result, hasLength(2));
      final thresholds =
          result.map((w) => w.thresholdSeconds).toSet();
      expect(thresholds, containsAll([600, 60]));
      expect(thresholds, isNot(contains(300)));
    });

    test('après mise à jour de la map, second appel ne notifie plus', () {
      final notified = <String, String>{};
      final status = [
        _status(scope: 'global', remainingSeconds: 599, exceeded: false),
      ];

      final first =
          ScreenTimeWarningService.computeWarnings(status, _today, notified);
      expect(first, hasLength(1));

      // Simuler la mise à jour effectuée par _tick()
      notified['global||600'] = _today;

      final second =
          ScreenTimeWarningService.computeWarnings(status, _today, notified);
      expect(second, isEmpty);
    });
  });

  // ─── Changement de jour ────────────────────────────────────────────────────

  group('changement de jour', () {
    test(
        'entrée dans notifiedDates datée d\'hier → '
        'nouvelle notif envoyée aujourd\'hui', () {
      final notified = <String, String>{'global||600': _yesterday};
      final result = ScreenTimeWarningService.computeWarnings(
        [_status(scope: 'global', remainingSeconds: 599, exceeded: false)],
        _today,
        notified,
      );
      expect(result, hasLength(1));
      expect(result.first.thresholdSeconds, equals(600));
    });

    test('toutes les entrées datées d\'hier → toutes les notifs ré-émises', () {
      final notified = <String, String>{
        'global||600': _yesterday,
        'global||300': _yesterday,
        'global||60': _yesterday,
      };
      final result = ScreenTimeWarningService.computeWarnings(
        [_status(scope: 'global', remainingSeconds: 59, exceeded: false)],
        _today,
        notified,
      );
      expect(result, hasLength(3));
    });
  });

  // ─── Limites multiples ─────────────────────────────────────────────────────

  group('limites multiples', () {
    test('limite globale + limite par app → avertissements indépendants', () {
      final result = ScreenTimeWarningService.computeWarnings(
        [
          _status(scope: 'global', remainingSeconds: 250, exceeded: false),
          _status(
            scope: 'app',
            remainingSeconds: 55,
            exceeded: false,
            packageName: 'com.tiktok.android',
          ),
        ],
        _today,
        {},
      );
      // global: 600 + 300 ; app: 600 + 300 + 60 = 5 warnings
      expect(result, hasLength(5));
    });

    test(
        'limite globale dépassée + limite app non dépassée → '
        'seule la limite app avertit', () {
      final result = ScreenTimeWarningService.computeWarnings(
        [
          _status(scope: 'global', remainingSeconds: 0, exceeded: true),
          _status(
            scope: 'app',
            remainingSeconds: 50,
            exceeded: false,
            packageName: 'com.example.social',
          ),
        ],
        _today,
        {},
      );
      final scopes = result.map((w) => w.scope).toSet();
      expect(scopes, isNot(contains('global')));
      expect(scopes, contains('app'));
    });
  });

  // ─── Textes ───────────────────────────────────────────────────────────────

  group('buildTitle', () {
    test('global 10 min', () {
      final t = ScreenTimeWarningService.buildTitle(
        const WarningToSend(scope: 'global', thresholdSeconds: 600),
      );
      expect(t, contains('10'));
      expect(t, contains('🌙'));
    });

    test('global 5 min', () {
      final t = ScreenTimeWarningService.buildTitle(
        const WarningToSend(scope: 'global', thresholdSeconds: 300),
      );
      expect(t, contains('5'));
    });

    test('global 1 min (singulier)', () {
      final t = ScreenTimeWarningService.buildTitle(
        const WarningToSend(scope: 'global', thresholdSeconds: 60),
      );
      expect(t, contains('1 minute'));
      expect(t, isNot(contains('minutes')));
    });

    test('app 10 min avec packageName', () {
      final t = ScreenTimeWarningService.buildTitle(
        const WarningToSend(
          scope: 'app',
          packageName: 'com.instagram.android',
          thresholdSeconds: 600,
        ),
      );
      expect(t, contains('Instagram'));
      expect(t, contains('🌸'));
    });

    test('app sans packageName → "cette app"', () {
      final t = ScreenTimeWarningService.buildTitle(
        const WarningToSend(scope: 'app', thresholdSeconds: 300),
      );
      expect(t, contains('cette app'));
    });
  });

  group('buildBody', () {
    test('1 min → message de pause', () {
      final b = ScreenTimeWarningService.buildBody(
        const WarningToSend(scope: 'global', thresholdSeconds: 60),
      );
      expect(b, contains('pause'));
      expect(b, contains('🌙'));
    });

    test('10 min global → mention "temps d\'écran"', () {
      final b = ScreenTimeWarningService.buildBody(
        const WarningToSend(scope: 'global', thresholdSeconds: 600),
      );
      expect(b, contains('temps d\'écran'));
    });

    test('5 min app → mention du nom de l\'app', () {
      final b = ScreenTimeWarningService.buildBody(
        const WarningToSend(
          scope: 'app',
          packageName: 'com.tiktok.android',
          thresholdSeconds: 300,
        ),
      );
      expect(b, contains('Tiktok'));
    });
  });

  // ─── friendlyName ─────────────────────────────────────────────────────────

  group('friendlyName', () {
    test('com.instagram.android → Instagram', () {
      expect(
        ScreenTimeWarningService.friendlyName('com.instagram.android'),
        equals('Instagram'),
      );
    });

    test('com.google.android.youtube → Android (avant-dernier segment)', () {
      // 'com.google.android.youtube' → avant-dernier = 'android'
      expect(
        ScreenTimeWarningService.friendlyName('com.google.android.youtube'),
        equals('Android'),
      );
    });

    test('com.tiktok → Tiktok', () {
      expect(
        ScreenTimeWarningService.friendlyName('com.tiktok'),
        equals('Tiktok'),
      );
    });

    test('null → "cette app"', () {
      expect(
        ScreenTimeWarningService.friendlyName(null),
        equals('cette app'),
      );
    });

    test('chaîne vide → "cette app"', () {
      expect(
        ScreenTimeWarningService.friendlyName(''),
        equals('cette app'),
      );
    });
  });
}
