import '../models/sos_alert.dart';

abstract interface class ISosAlertRepository {
  Future<void> trigger(SosAlert alert);
  Future<List<SosAlert>> getActive();
  Future<List<SosAlert>> getAll();
  Future<void> acknowledge(String alertId);
  Future<void> resolve(String alertId);
}
