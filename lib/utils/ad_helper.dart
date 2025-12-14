import 'package:hustlecoin/services/admob_service.dart';

class AdHelper {
  static final AdMobService _adMobService = AdMobService();

  /// Shows an interstitial ad with a probability check
  /// Returns true if ad was shown, false otherwise
  static Future<bool> showInterstitialAd({double probability = 0.3}) async {
    // Random chance to show ad (30% by default)
    if (DateTime.now().millisecondsSinceEpoch % 100 >= (probability * 100)) {
      return false;
    }

    if (_adMobService.isInterstitialAdLoaded) {
      final shown = await _adMobService.showInterstitialAd();
      if (!shown) {
        _adMobService.loadInterstitialAd(); // Preload for next time
      }
      return shown;
    } else {
      await _adMobService.loadInterstitialAd();
      return false;
    }
  }

  /// Shows an interstitial ad after task completion
  static Future<void> showInterstitialAfterTask() async {
    await showInterstitialAd(
      probability: 0.5,
    ); // 50% chance after task completion
  }

  /// Shows an interstitial ad during navigation
  static Future<void> showInterstitialOnNavigation() async {
    await showInterstitialAd(probability: 0.2); // 20% chance on navigation
  }
}
