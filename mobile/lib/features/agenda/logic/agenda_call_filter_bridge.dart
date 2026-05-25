import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../call_filter/domain/filter_mode_manager.dart';
import '../data/repositories/agenda_event_repository.dart';
import '../data/repositories/i_agenda_event_repository.dart';

/// Surveille les événements importants en cours et pilote le Mode Focus
/// du module Call Filter en conséquence.
///
/// - Active HarmonyFilterMode.focus dès qu'un événement important est en cours.
/// - Désactive (retour à .off) 15 min après la fin du dernier événement important.
class AgendaCallFilterBridge extends ChangeNotifier {
  AgendaCallFilterBridge({
    required FilterModeManager filterModeManager,
    IAgendaEventRepository? repository,
    Duration pollInterval = const Duration(minutes: 1),
  })  : _filterModeManager = filterModeManager,
        _repository = repository ?? AgendaEventRepository.instance,
        _pollInterval = pollInterval;

  final FilterModeManager _filterModeManager;
  final IAgendaEventRepository _repository;
  final Duration _pollInterval;

  Timer? _timer;
  bool _focusActive = false;
  DateTime? _lastEventEndedAt;

  static const _focusGracePeriod = Duration(minutes: 15);

  bool get isFocusActive => _focusActive;

  /// Démarre la surveillance périodique.
  void start() {
    _timer?.cancel();
    _tick();
    _timer = Timer.periodic(_pollInterval, (_) => _tick());
  }

  /// Arrête la surveillance et libère les ressources.
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _tick() async {
    final importantNow = await _repository.getImportantEventsNow();

    if (importantNow.isNotEmpty) {
      _lastEventEndedAt = null;
      if (!_focusActive) {
        _focusActive = true;
        _filterModeManager.activate(HarmonyFilterMode.focus);
        notifyListeners();
      }
      return;
    }

    // Plus d'événements importants — démarre / continue la période de grâce
    if (_focusActive) {
      _lastEventEndedAt ??= DateTime.now();
      final elapsed = DateTime.now().difference(_lastEventEndedAt!);
      if (elapsed >= _focusGracePeriod) {
        _focusActive = false;
        _lastEventEndedAt = null;
        _filterModeManager.activate(HarmonyFilterMode.off);
        notifyListeners();
      }
    }
  }

  /// Force un re-check immédiat (utile après ajout/modification d'un événement).
  Future<void> refresh() => _tick();
}
