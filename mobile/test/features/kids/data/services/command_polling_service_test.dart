import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/kids/data/services/command_polling_service.dart';

void main() {
  group('CommandPollingService', () {
    final service = CommandPollingService.instance;

    tearDown(() => service.stop());

    test('n\'est pas en cours au démarrage', () {
      expect(service.isRunning, isFalse);
    });

    test('isRunning passe à true après start()', () {
      service.start('test-child-id');
      expect(service.isRunning, isTrue);
    });

    test('isRunning repasse à false après stop()', () {
      service.start('test-child-id');
      service.stop();
      expect(service.isRunning, isFalse);
    });

    test('start() est idempotent pour le même child_id', () {
      service.start('test-child-id');
      service.start('test-child-id'); // second appel — ne doit pas planter
      expect(service.isRunning, isTrue);
    });

    test('start() avec un nouveau child_id redémarre le polling', () {
      service.start('child-1');
      service.start('child-2');
      expect(service.isRunning, isTrue);
    });
  });
}
