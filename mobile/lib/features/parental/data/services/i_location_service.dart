import '../models/location_point.dart';

enum TrackingMode { standard, powersaver }

enum LocationPermissionStatus { granted, grantedBackground, denied, permanentlyDenied }

abstract interface class ILocationService {
  /// Démarre le tracking GPS selon le mode choisi.
  Future<void> startTracking({TrackingMode mode = TrackingMode.standard});

  /// Arrête le tracking.
  Future<void> stopTracking();

  /// Retourne la position courante une seule fois.
  Future<LocationPoint?> getCurrentPosition(String childId);

  /// Stream de positions en temps réel.
  Stream<LocationPoint> positionStream(String childId);

  /// Demande les permissions localisation (foreground puis background).
  Future<LocationPermissionStatus> requestPermissions();

  /// Vérifie le statut courant des permissions sans les demander.
  Future<LocationPermissionStatus> checkPermissions();
}
