import 'package:flutter_test/flutter_test.dart';

import 'package:harmony/features/kids/data/services/screen_time_blocking_service.dart';
import 'package:harmony/features/kids/data/services/screen_time_limits_fetch_service.dart';

// ─── Stubs ────────────────────────────────────────────────────────────────────

/// Sous-classe exposant computeBlockDecision — pas d'appels MethodChannel.
class _TestBlockingService extends ScreenTimeBlockingService {
  _TestBlockingService() : super();
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

KidsScreenTimeStatus _status({
  required String scope,
  required bool exceeded,
  String? packageName,
}) {
  return KidsScreenTimeStatus(
    scope: scope,
    limitSeconds: 3600,
    usedSeconds: exceeded ? 4000 : 100,
    remainingSeconds: exceeded ? 0 : 3500,
    exceeded: exceeded,
    packageName: packageName,
  );
}

void main() {
  final svc = _TestBlockingService();

  // ─── computeBlockDecision ─────────────────────────────────────────────────

  group('computeBlockDecision', () {
    test('liste vide → aucun blocage', () {
      final d = svc.computeBlockDecision([]);
      expect(d.globalBlocked, isFalse);
      expect(d.blockedPackages, isEmpty);
      expect(d.isEmpty, isTrue);
    });

    test('limites non dépassées → aucun blocage', () {
      final d = svc.computeBlockDecision([
        _status(scope: 'global', exceeded: false),
        _status(scope: 'app', exceeded: false, packageName: 'com.example.app'),
      ]);
      expect(d.globalBlocked, isFalse);
      expect(d.blockedPackages, isEmpty);
    });

    test('quota global dépassé → globalBlocked = true', () {
      final d = svc.computeBlockDecision([
        _status(scope: 'global', exceeded: true),
      ]);
      expect(d.globalBlocked, isTrue);
      expect(d.blockedPackages, isEmpty);
      expect(d.isEmpty, isFalse);
    });

    test('limite par app dépassée → package dans blockedPackages', () {
      final d = svc.computeBlockDecision([
        _status(scope: 'app', exceeded: true, packageName: 'com.example.game'),
      ]);
      expect(d.globalBlocked, isFalse);
      expect(d.blockedPackages, contains('com.example.game'));
    });

    test('quota global + limite app → les deux flags actifs', () {
      final d = svc.computeBlockDecision([
        _status(scope: 'global', exceeded: true),
        _status(scope: 'app', exceeded: true, packageName: 'com.example.game'),
        _status(scope: 'app', exceeded: true, packageName: 'com.example.social'),
      ]);
      expect(d.globalBlocked, isTrue);
      expect(d.blockedPackages, containsAll(['com.example.game', 'com.example.social']));
    });

    test('scope app sans packageName → ignoré', () {
      final d = svc.computeBlockDecision([
        _status(scope: 'app', exceeded: true, packageName: null),
      ]);
      expect(d.blockedPackages, isEmpty);
    });

    test('seule la limite non dépassée → pas de blocage même si d\'autres existent', () {
      final d = svc.computeBlockDecision([
        _status(scope: 'global', exceeded: false),
        _status(scope: 'app', exceeded: false, packageName: 'com.example.ok'),
      ]);
      expect(d.isEmpty, isTrue);
    });
  });

  // ─── shouldBlock ──────────────────────────────────────────────────────────

  group('shouldBlock', () {
    const appPackage = 'com.example.game';

    test('package dans neverBlock → jamais bloqué même si global', () {
      final d = BlockDecision(globalBlocked: true, blockedPackages: ['com.harmony.harmony']);
      expect(
        ScreenTimeBlockingService.shouldBlock('com.harmony.harmony', d),
        isFalse,
      );
    });

    test('com.android.systemui → jamais bloqué', () {
      final d = BlockDecision(globalBlocked: true, blockedPackages: []);
      expect(
        ScreenTimeBlockingService.shouldBlock('com.android.systemui', d),
        isFalse,
      );
    });

    test('launcher Samsung → jamais bloqué', () {
      final d = BlockDecision(globalBlocked: true, blockedPackages: []);
      expect(
        ScreenTimeBlockingService.shouldBlock('com.sec.android.app.launcher', d),
        isFalse,
      );
    });

    test('appel d\'urgence → jamais bloqué', () {
      final d = BlockDecision(globalBlocked: true, blockedPackages: []);
      expect(
        ScreenTimeBlockingService.shouldBlock('com.android.emergency', d),
        isFalse,
      );
    });

    test('package dans blockedPackages → bloqué', () {
      final d = BlockDecision(globalBlocked: false, blockedPackages: [appPackage]);
      expect(ScreenTimeBlockingService.shouldBlock(appPackage, d), isTrue);
    });

    test('globalBlocked = true → package ordinaire bloqué', () {
      final d = BlockDecision(globalBlocked: true, blockedPackages: []);
      expect(ScreenTimeBlockingService.shouldBlock(appPackage, d), isTrue);
    });

    test('aucun blocage → package ordinaire libre', () {
      final d = BlockDecision(globalBlocked: false, blockedPackages: []);
      expect(ScreenTimeBlockingService.shouldBlock(appPackage, d), isFalse);
    });

    test('neverBlock a priorité sur blockedPackages', () {
      final d = BlockDecision(
        globalBlocked: false,
        blockedPackages: ['com.google.android.dialer'],
      );
      expect(
        ScreenTimeBlockingService.shouldBlock('com.google.android.dialer', d),
        isFalse,
      );
    });
  });

  // ─── BlockDecision.isEmpty ─────────────────────────────────────────────────

  group('BlockDecision.isEmpty', () {
    test('vide si aucun blocage', () {
      expect(
        const BlockDecision(globalBlocked: false, blockedPackages: []).isEmpty,
        isTrue,
      );
    });

    test('non vide si globalBlocked', () {
      expect(
        const BlockDecision(globalBlocked: true, blockedPackages: []).isEmpty,
        isFalse,
      );
    });

    test('non vide si liste non vide', () {
      expect(
        const BlockDecision(
          globalBlocked: false,
          blockedPackages: ['com.x.y'],
        ).isEmpty,
        isFalse,
      );
    });
  });
}
