import 'package:flutter/foundation.dart';
import 'package:hustlecoin/services/admob_service.dart';

/// Debug helper to diagnose AdMob issues in release mode
class AdMobDebugHelper {
  static void printAdMobDiagnostics() {
    print('=== ADMOB DIAGNOSTICS ===');
    print('Debug Mode: $kDebugMode');
    print('Release Mode: ${!kDebugMode}');
    
    final adService = AdMobService();
    
    // Test ad unit IDs
    print('\n--- AD UNIT IDs ---');
    print('Rewarded: ${AdMobService.rewardedAdUnitId}');
    print('Banner: ${AdMobService.bannerAdUnitId}'); 
    print('Interstitial: ${AdMobService.interstitialAdUnitId}');
    print('App Open: ${AdMobService.appOpenAdUnitId}');
    
    // Ad loading states
    print('\n--- AD LOADING STATES ---');
    print('Rewarded Ad Loaded: ${adService.isRewardedAdLoaded}');
    print('Banner Ad Loaded: ${adService.isBannerAdLoaded}');
    print('Interstitial Ad Loaded: ${adService.isInterstitialAdLoaded}');
    print('App Open Ad Loaded: ${adService.isAppOpenAdLoaded}');
    
    print('=== END DIAGNOSTICS ===\n');
  }
  
  /// Call this method to test ad loading in release mode
  static Future<void> testAdLoadingInRelease() async {
    if (kDebugMode) {
      print('AdMobDebugHelper: Cannot test release mode - currently in debug mode');
      return;
    }
    
    print('AdMobDebugHelper: Testing ad loading in RELEASE mode...');
    
    final adService = AdMobService();
    
    // Test rewarded ad loading
    print('Testing rewarded ad loading...');
    try {
      await adService.loadRewardedAd();
      await Future.delayed(const Duration(seconds: 3));
      print('Rewarded ad loading result: ${adService.isRewardedAdLoaded}');
    } catch (e) {
      print('Rewarded ad loading error: $e');
    }
    
    // Test interstitial ad loading  
    print('Testing interstitial ad loading...');
    try {
      await adService.loadInterstitialAd();
      await Future.delayed(const Duration(seconds: 3));
      print('Interstitial ad loading result: ${adService.isInterstitialAdLoaded}');
    } catch (e) {
      print('Interstitial ad loading error: $e');
    }
  }
}