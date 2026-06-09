class SosContact {
  const SosContact({
    required this.id,
    required this.childId,
    required this.name,
    required this.phone,
    required this.createdBy,
    required this.sortOrder,
  });

  final String id;
  final String childId;
  final String name;
  final String phone;
  final String createdBy;
  final int sortOrder;

  factory SosContact.fromJson(Map<String, dynamic> j) => SosContact(
        id: j['id'] as String,
        childId: j['child_id'] as String,
        name: j['name'] as String,
        phone: j['phone'] as String,
        createdBy: j['created_by'] as String,
        sortOrder: j['sort_order'] as int? ?? 0,
      );
}
