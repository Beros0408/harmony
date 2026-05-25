import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../models/location_point.dart';
import 'i_location_service.dart';

/// Implémentation réelle via geolocator.
/// Non instanciée en tests — passer ILocationService comme dépendance.
class LocationService implements ILocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  static const _uuid = Uuid();

  StreamSubscription<Position>? _subscription;
  final _controller = StreamController<LocationPoint>.broadcast();

  @override
  Future<LocationPermissionStatus> checkPermissions() async {
    final perm = await Geolocator.checkPermission();
    return _mapPermission(perm);
  }

  @override
  Future<LocationPermissionStatus> requestPermissions() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.whileInUse) {
      // Tente la permission background (Android 10+)
      perm = await Geolocator.requestPermission();
    }
    return _mapPermission(perm);
  }

  @override
  Future<void> startTracking({TrackingMode mode = TrackingMode.standard}) async {
    await _subscription?.cancel();

    final settings = _settingsFor(mode);
    _subscription = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) => _controller.add(_positionToPoint(pos, 'current')),
      onError: (_) {},
    );
  }

  @override
  Future<void> stopTracking() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<LocationPoint?> getCurrentPosition(String childId) async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _positionToPoint(pos, childId);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<LocationPoint> positionStream(String childId) => _controller.stream;

  // ─── Helpers ─────────────────────────────────────────────────────────────

  LocationSettings _settingsFor(TrackingMode mode) {
    switch (mode) {
      case TrackingMode.powersaver:
        return const LocationSettings(
          accuracy: LocationAccuracy.reduced,
          distanceFilter: 100,
        );
      case TrackingMode.standard:
        return const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        );
    }
  }

  LocationPoint _positionToPoint(Position pos, String childId) => LocationPoint(
        id: _uuid.v4(),
        childId: childId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        timestamp: pos.timestamp,
      );

  LocationPermissionStatus _mapPermission(LocationPermission perm) => switch (perm) {
        LocationPermission.always => LocationPermissionStatus.grantedBackground,
        LocationPermission.whileInUse => LocationPermissionStatus.granted,
        LocationPermission.denied => LocationPermissionStatus.denied,
        LocationPermission.deniedForever => LocationPermissionStatus.permanentlyDenied,
        _ => LocationPermissionStatus.denied,
      };
}
