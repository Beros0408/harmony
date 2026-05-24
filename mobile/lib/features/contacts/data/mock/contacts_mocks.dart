enum ContactGroup { whitelist, blacklist }

class HarmonyContact {
  const HarmonyContact({
    required this.name,
    required this.phone,
    required this.group,
  });

  final String name;
  final String phone;
  final ContactGroup group;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}

const kContacts = [
  HarmonyContact(
    name: 'Alice Dupont',
    phone: '+33 6 12 34 56 78',
    group: ContactGroup.whitelist,
  ),
  HarmonyContact(
    name: 'Bob Martin',
    phone: '+33 7 98 76 54 32',
    group: ContactGroup.whitelist,
  ),
  HarmonyContact(
    name: 'Marie Lefebvre',
    phone: '+33 6 55 44 33 22',
    group: ContactGroup.whitelist,
  ),
  HarmonyContact(
    name: 'Spam Téléphonie',
    phone: '+33 1 23 45 67 89',
    group: ContactGroup.blacklist,
  ),
  HarmonyContact(
    name: 'Démarcheur SFR',
    phone: '+33 9 87 65 43 21',
    group: ContactGroup.blacklist,
  ),
];
