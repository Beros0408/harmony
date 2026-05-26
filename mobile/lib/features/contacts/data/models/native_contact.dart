class NativeContact {
  const NativeContact({
    required this.id,
    required this.displayName,
    this.phone,
  });

  final String id;
  final String displayName;
  final String? phone;

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return displayName.substring(0, displayName.length.clamp(0, 2)).toUpperCase();
  }
}
