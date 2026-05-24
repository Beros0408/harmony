import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/call_filter/data/mock/security_mocks.dart';
import 'package:harmony/features/call_filter/data/repositories/blacklist_repository.dart';
import 'package:harmony/features/contacts/data/mock/contacts_mocks.dart';

const _channel = MethodChannel('com.harmony.app/call_filter');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Capture des appels syncRules envoyés au channel natif
  final capturedCalls = <MethodCall>[];

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      capturedCalls.add(call);
      return null;
    });
  });

  setUp(() => capturedCalls.clear());

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  group('BlacklistRepository — syncToNative', () {
    test('envoie la whitelist et la blacklist initiales depuis kContacts', () async {
      await BlacklistRepository.instance.syncToNative();

      expect(capturedCalls, hasLength(1));
      final call = capturedCalls.first;
      expect(call.method, 'syncRules');

      final rules = (call.arguments as Map)['rules'] as List;
      final whitelistRules = rules.where((r) => r['type'] == 'whitelist').toList();
      final blacklistRules = rules.where((r) => r['type'] == 'blacklist').toList();

      final expectedWhitelist = kContacts.where((c) => c.group == ContactGroup.whitelist).length;
      final expectedBlacklist = kContacts.where((c) => c.group == ContactGroup.blacklist).length;

      expect(whitelistRules, hasLength(expectedWhitelist));
      expect(blacklistRules, hasLength(expectedBlacklist));
    });

    test('inclut la règle de mode (normal par défaut)', () async {
      await BlacklistRepository.instance.syncToNative();

      final rules = (capturedCalls.first.arguments as Map)['rules'] as List;
      final modeRule = rules.firstWhere((r) => r['type'] == 'mode', orElse: () => null);
      expect(modeRule, isNotNull);
      expect(modeRule['value'], 'normal');
    });

    test('setMode déclenche un syncRules avec la nouvelle valeur de mode', () async {
      await BlacklistRepository.instance.setMode(FilterModeType.focus);

      expect(capturedCalls, hasLength(1));
      final rules = (capturedCalls.first.arguments as Map)['rules'] as List;
      final modeRule = rules.firstWhere((r) => r['type'] == 'mode');
      expect(modeRule['value'], 'focus');

      // Remettre en normal pour ne pas polluer d'autres tests
      await BlacklistRepository.instance.setMode(FilterModeType.normal);
    });
  });
}
