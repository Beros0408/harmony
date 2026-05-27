import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/services/feature_gating_service.dart';

/// Bannière AdMob responsive.
/// Masquée si l'utilisateur est Premium ([FeatureGatingService.hasPremium]).
/// Utilise les Ad Unit IDs de test — remplacer par les vraies clés en prod.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  // Test Ad Unit IDs (Android + iOS)
  static const String _androidTestId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _iosTestId = 'ca-app-pub-3940256099942544/2934735716';

  @override
  void initState() {
    super.initState();
    if (!FeatureGatingService.instance.hasPremium()) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final adUnitId = Theme.of(context).platform == TargetPlatform.iOS
        ? _iosTestId
        : _androidTestId;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          // ignore: avoid_print
          print('[ADS-DEBUG] Banner failed: ${error.message}');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (FeatureGatingService.instance.hasPremium()) return const SizedBox.shrink();
    if (!_loaded || _bannerAd == null) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
