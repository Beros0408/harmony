import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/call_filter/domain/filter_mode_manager.dart';

void main() {
  group('FilterModeManager', () {
    test('état initial : off', () {
      final manager = FilterModeManager();
      expect(manager.current, HarmonyFilterMode.off);
    });

    test('activate change le mode', () {
      final manager = FilterModeManager();
      manager.activate(HarmonyFilterMode.night);
      expect(manager.current, HarmonyFilterMode.night);
    });

    test('activate le même mode ne notifie pas', () {
      final manager = FilterModeManager();
      var notified = 0;
      manager.addListener(() => notified++);
      manager.activate(HarmonyFilterMode.off);
      expect(notified, 0);
    });

    test('activate un mode différent notifie', () {
      final manager = FilterModeManager();
      var notified = 0;
      manager.addListener(() => notified++);
      manager.activate(HarmonyFilterMode.focus);
      expect(notified, 1);
    });

    test('activate emergency puis off', () {
      final manager = FilterModeManager();
      manager.activate(HarmonyFilterMode.emergency);
      expect(manager.current, HarmonyFilterMode.emergency);
      manager.activate(HarmonyFilterMode.off);
      expect(manager.current, HarmonyFilterMode.off);
    });
  });

  group('FilterModeManager — toNativeValue', () {
    late FilterModeManager manager;
    setUp(() => manager = FilterModeManager());

    test('off → normal', () => expect(manager.toNativeValue(HarmonyFilterMode.off), 'normal'));
    test('night → night', () => expect(manager.toNativeValue(HarmonyFilterMode.night), 'night'));
    test('work → work', () => expect(manager.toNativeValue(HarmonyFilterMode.work), 'work'));
    test('focus → focus', () => expect(manager.toNativeValue(HarmonyFilterMode.focus), 'focus'));
    test('weekend → weekend', () => expect(manager.toNativeValue(HarmonyFilterMode.weekend), 'weekend'));
    test('emergency → emergency', () => expect(manager.toNativeValue(HarmonyFilterMode.emergency), 'emergency'));
  });

  group('kHarmonyFilterModes', () {
    test('contient 6 modes', () {
      expect(kHarmonyFilterModes.length, 6);
    });

    test('tous les modes sont représentés', () {
      final modes = kHarmonyFilterModes.map((m) => m.mode).toSet();
      for (final m in HarmonyFilterMode.values) {
        expect(modes, contains(m));
      }
    });
  });
}
