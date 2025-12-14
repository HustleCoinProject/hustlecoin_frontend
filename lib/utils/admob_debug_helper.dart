import 'package:flutter/foundation.dart';
import 'package:hustlecoin/services/admob_service.dart';

/// Debug helper to diagnose AdMob issues in release mode
class AdMobDebugHelper {
  static void printAdMobDiagnostics() {
    final adService = AdMobService();
  }
  
  /// Call this method to test ad loading in release mode
  static Future<void> testAdLoadingInRelease() async {
    if (kDebugMode) {
      return;
    }
    
    final adService = AdMobService();
    
    // Test rewarded ad loading
    try {
      await adService.loadRewardedAd();
      await Future.delayed(const Duration(seconds: 3));
    } catch (e) {
    }
    
    // Test interstitial ad loading  
    try {
      await adService.loadInterstitialAd();
      await Future.delayed(const Duration(seconds: 3));
    } catch (e) {
    }
  }
}