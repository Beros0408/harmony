import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

/// Modes de transport supportés par Google Distance Matrix API.
enum TravelMode { driving, walking, cycling, transit }

/// Résultat du calcul de temps de trajet.
class TravelTimeResult {
  const TravelTimeResult({
    required this.durationMinutes,
    required this.distanceMeters,
    required this.isEstimated,
  });

  final int durationMinutes;
  final int distanceMeters;

  /// true si le résultat provient de l'estimation locale (API indisponible)
  final bool isEstimated;
}

/// Calcule le temps de trajet entre deux points.
/// Utilise Google Distance Matrix API avec cache mémoire 10 min.
/// Fallback : estimation vitesse/distance si l'API est indisponible.
class TravelTimeService {
  TravelTimeService._();

  static final TravelTimeService instance = TravelTimeService._();

  // Cache: clé → (résultat, timestamp)
  final Map<String, (TravelTimeResult, DateTime)> _cache = {};
  static const _cacheTtl = Duration(minutes: 10);

  // Vitesses de repli en km/h par mode (estimation grossière)
  static const _fallbackSpeedKmh = {
    TravelMode.driving: 50.0,
    TravelMode.walking: 5.0,
    TravelMode.cycling: 15.0,
    TravelMode.transit: 30.0,
  };

  String? _apiKey;

  void configure(String googleApiKey) {
    _apiKey = googleApiKey;
  }

  Future<TravelTimeResult> calculateTravelTime({
    required String origin,
    required String destination,
    TravelMode mode = TravelMode.driving,
  }) async {
    final cacheKey = '${origin}_${destination}_${mode.name}';
    final cached = _cache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.$2) < _cacheTtl) {
      return cached.$1;
    }

    final result = _apiKey != null
        ? await _fetchFromApi(origin, destination, mode)
        : null;

    final finalResult = result ?? _estimateLocally(origin, destination, mode);
    _cache[cacheKey] = (finalResult, DateTime.now());
    return finalResult;
  }

  Future<TravelTimeResult?> _fetchFromApi(
    String origin,
    String destination,
    TravelMode mode,
  ) async {
    try {
      final modeStr = switch (mode) {
        TravelMode.driving => 'driving',
        TravelMode.walking => 'walking',
        TravelMode.cycling => 'bicycling',
        TravelMode.transit => 'transit',
      };

      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/distancematrix/json',
        {
          'origins': origin,
          'destinations': destination,
          'mode': modeStr,
          'key': _apiKey!,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['status'] != 'OK') return null;

      final rows = json['rows'] as List<dynamic>;
      if (rows.isEmpty) return null;

      final elements =
          (rows.first as Map<String, dynamic>)['elements'] as List<dynamic>;
      if (elements.isEmpty) return null;

      final element = elements.first as Map<String, dynamic>;
      if (element['status'] != 'OK') return null;

      final duration =
          (element['duration'] as Map<String, dynamic>)['value'] as int;
      final distance =
          (element['distance'] as Map<String, dynamic>)['value'] as int;

      return TravelTimeResult(
        durationMinutes: (duration / 60).ceil(),
        distanceMeters: distance,
        isEstimated: false,
      );
    } catch (_) {
      return null;
    }
  }

  /// Estimation grossière : parse latitude/longitude si possible,
  /// sinon retourne une durée par défaut selon le mode.
  TravelTimeResult _estimateLocally(
    String origin,
    String destination,
    TravelMode mode,
  ) {
    final originLatLng = _parseLatLng(origin);
    final destLatLng = _parseLatLng(destination);

    if (originLatLng != null && destLatLng != null) {
      final distanceKm = _haversineKm(originLatLng, destLatLng);
      final speed = _fallbackSpeedKmh[mode]!;
      final durationMin = ((distanceKm / speed) * 60).ceil();
      return TravelTimeResult(
        durationMinutes: durationMin.clamp(1, 999),
        distanceMeters: (distanceKm * 1000).round(),
        isEstimated: true,
      );
    }

    // Durée par défaut si pas de coordonnées parsables
    final defaultMin = switch (mode) {
      TravelMode.driving => 15,
      TravelMode.walking => 30,
      TravelMode.cycling => 20,
      TravelMode.transit => 25,
    };
    return TravelTimeResult(
      durationMinutes: defaultMin,
      distanceMeters: 0,
      isEstimated: true,
    );
  }

  (double lat, double lng)? _parseLatLng(String s) {
    final parts = s.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

  // Distance Haversine en km entre deux points GPS
  double _haversineKm((double, double) a, (double, double) b) {
    const r = 6371.0;
    final dLat = _toRad(b.$1 - a.$1);
    final dLng = _toRad(b.$2 - a.$2);
    final h = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRad(a.$1)) *
            math.cos(_toRad(b.$1)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * r * math.asin(math.sqrt(h.toDouble()));
  }

  double _toRad(double deg) => deg * math.pi / 180;

  void clearCache() => _cache.clear();
}
