import 'package:harmony/features/call_filter/data/models/blacklist_entry.dart';

abstract class IBlacklistRepository {
  Future<List<BlacklistEntry>> getAll();
  Future<BlacklistEntry?> getById(String id);
  Future<BlacklistEntry?> getByNumber(String phoneNumber);
  Future<void> add(BlacklistEntry entry);
  Future<void> update(BlacklistEntry entry);
  Future<void> delete(String id);
  Future<void> clear();
  Future<List<BlacklistEntry>> search(String query);
  Future<void> syncToNative();
}
