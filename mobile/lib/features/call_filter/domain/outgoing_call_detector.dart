/// Risk level for an outgoing call number assessment.
enum OutgoingCallRiskLevel { safe, warning, danger }

/// Result of assessing an outgoing phone number.
class OutgoingCallRisk {
  const OutgoingCallRisk({
    required this.level,
    required this.reason,
    this.estimatedCostPerMinute,
  });

  final OutgoingCallRiskLevel level;
  final String reason;
  // Estimated cost in EUR/min for FR premium numbers; null when unknown.
  final double? estimatedCostPerMinute;

  bool get isSafe => level == OutgoingCallRiskLevel.safe;
}

/// Pure-Dart assessor for outgoing call risk.
/// No platform channel — runs before the call is placed, synchronously.
class OutgoingCallDetector {
  const OutgoingCallDetector({this.allowedCountryCodes = const ['+33', '+32', '+41', '+1']});

  final List<String> allowedCountryCodes;

  // FR premium / surtaxed prefixes (ARCEP list)
  static const _frPremiumPrefixes = [
    '0899', '0898', '0897', '0896', '0895',
    '0894', '0893', '0892', '0891', '0890',
  ];

  // US premium
  static const _usPremiumPrefixes = ['+1900'];

  /// Returns the risk assessment for [phoneNumber].
  OutgoingCallRisk assess(String phoneNumber) {
    final normalized = _normalize(phoneNumber);

    // FR surtaxed
    for (final prefix in _frPremiumPrefixes) {
      if (normalized.startsWith(prefix)) {
        return OutgoingCallRisk(
          level: OutgoingCallRiskLevel.danger,
          reason: 'Numéro surtaxé ($prefix…)',
          estimatedCostPerMinute: _frPremiumCost(prefix),
        );
      }
    }

    // US premium
    for (final prefix in _usPremiumPrefixes) {
      if (normalized.startsWith(prefix)) {
        return const OutgoingCallRisk(
          level: OutgoingCallRiskLevel.danger,
          reason: 'Numéro surtaxé (+1 900…)',
          estimatedCostPerMinute: 3.0,
        );
      }
    }

    // International — check against allowed country codes
    if (normalized.startsWith('+')) {
      final allowed = allowedCountryCodes.any((cc) => normalized.startsWith(cc));
      if (!allowed) {
        return const OutgoingCallRisk(
          level: OutgoingCallRiskLevel.warning,
          reason: 'Numéro international (coûts potentiels)',
        );
      }
    }

    return const OutgoingCallRisk(
      level: OutgoingCallRiskLevel.safe,
      reason: 'Numéro standard',
    );
  }

  /// Strips spaces, dashes, dots and parentheses; keeps +, digits.
  static String _normalize(String raw) =>
      raw.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');

  static double _frPremiumCost(String prefix) => switch (prefix) {
        '0899' => 1.50,
        '0898' => 0.80,
        '0897' => 0.60,
        '0896' => 0.45,
        '0895' => 0.35,
        '0894' => 0.30,
        '0893' => 0.40,
        '0892' => 0.34,
        '0891' => 0.15,
        '0890' => 0.06,
        _ => 0.0,
      };
}
