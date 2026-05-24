import 'package:flutter/foundation.dart';
import 'package:harmony/features/call_filter/data/mock/security_mocks.dart';
import 'package:harmony/features/call_filter/data/native/call_filter_channel.dart';
import 'package:harmony/features/contacts/data/mock/contacts_mocks.dart';

/// In-memory repository for whitelist/blacklist contacts.
/// Singleton — initialised from [kContacts]; updated at runtime by UI actions.
///
/// Calls [CallFilterChannel.syncRules] whenever the lists or the active mode change,
/// keeping the Kotlin [CallDecisionEngine] snapshot in sync at all times.
class BlacklistRepository extends ChangeNotifier {
  BlacklistRepository._() {
    _contacts = List<HarmonyContact>.of(kContacts);
  }

  static final BlacklistRepository instance = BlacklistRepository._();

  late List<HarmonyContact> _contacts;
  FilterModeType _mode = FilterModeType.normal;

  // ──────────────────────────────── Getters ────────────────────────────────

  List<HarmonyContact> get contacts => List.unmodifiable(_contacts);

  List<String> get whitelistNumbers => _contacts
      .where((c) => c.group == ContactGroup.whitelist)
      .map((c) => c.phone)
      .toList();

  List<String> get blacklistNumbers => _contacts
      .where((c) => c.group == ContactGroup.blacklist)
      .map((c) => c.phone)
      .toList();

  FilterModeType get mode => _mode;

  // ──────────────────────────────── Mutations ──────────────────────────────

  /// Changes the active filter mode and syncs to native immediately.
  Future<void> setMode(FilterModeType newMode) async {
    if (_mode == newMode) return;
    _mode = newMode;
    notifyListeners();
    await syncToNative();
  }

  /// Adds a contact and syncs to native.
  Future<void> addContact(HarmonyContact contact) async {
    _contacts = [..._contacts, contact];
    notifyListeners();
    await syncToNative();
  }

  /// Removes a contact by phone number and syncs to native.
  Future<void> removeContact(String phone) async {
    _contacts = _contacts.where((c) => c.phone != phone).toList();
    notifyListeners();
    await syncToNative();
  }

  // ──────────────────────────────── Native sync ────────────────────────────

  /// Pushes the current whitelist + blacklist + mode to the Kotlin engine.
  /// Safe to call repeatedly — the engine replaces the snapshot atomically.
  Future<void> syncToNative() async {
    final rules = <CallRule>[
      for (final n in whitelistNumbers)
        CallRule(type: CallRuleType.whitelist, phoneNumber: n),
      for (final n in blacklistNumbers)
        CallRule(type: CallRuleType.blacklist, phoneNumber: n),
      CallRule(type: CallRuleType.mode, value: _modeString(_mode)),
    ];
    await CallFilterChannel.syncRules(rules);
    debugPrint(
      '[BlacklistRepository] syncToNative — '
      '${whitelistNumbers.length} whitelist, ${blacklistNumbers.length} blacklist, mode=${_modeString(_mode)}',
    );
  }

  // ──────────────────────────────── Helpers ────────────────────────────────

  static String _modeString(FilterModeType mode) => switch (mode) {
        FilterModeType.normal => 'normal',
        FilterModeType.focus => 'focus',
        FilterModeType.night => 'night',
      };
}
