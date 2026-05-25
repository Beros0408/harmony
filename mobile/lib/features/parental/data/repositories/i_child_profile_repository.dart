import '../models/child_profile.dart';

abstract interface class IChildProfileRepository {
  Future<List<ChildProfile>> getAll();
  Future<ChildProfile?> getById(String id);
  Future<void> add(ChildProfile profile);
  Future<void> update(ChildProfile profile);
  Future<void> delete(String id);
  Future<void> seed(List<ChildProfile> profiles);
}
