import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AdMobService {
  static const String _testAdUnitId =
      'ca-app-pub-3940256099942544/5224354917'; // Test ad unit
  static const String _adUnitId =
      'ca-app-pub-3737974268376998/7706125192'; // Your actual ad unit

  // Use test ad in debug mode, real ad in release mode
  static String get adUnitId {
    final id = kDebugMode ? _testAdUnitId : _adUnitId;
    print(
      'DEBUG: AdMobService - Using ad unit ID: $id (Debug mode: $kDebugMode)',
    );
    return id;
  }

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  // Singleton pattern
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  bool get isAdLoaded {
    print(
      'DEBUG: AdMobService - isAdLoaded called, current state: $_isAdLoaded',
    );
    return _isAdLoaded;
  }

  Future<void> loadRewardedAd() async {
    print('DEBUG: AdMobService - Starting to load rewarded ad...');
    print(
      'DEBUG: AdMobService - Current ad state before loading: _isAdLoaded=$_isAdLoaded, _rewardedAd=$_rewardedAd',
    );

    final currentAdUnitId = adUnitId;
    print('DEBUG: AdMobService - Loading ad with unit ID: $currentAdUnitId');

    try {
      await RewardedAd.load(
        adUnitId: currentAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('DEBUG: AdMobService - ✅ Rewarded ad loaded successfully!');
            print('DEBUG: AdMobService - Ad details: ${ad.toString()}');
            _rewardedAd = ad;
            _isAdLoaded = true;
            print(
              'DEBUG: AdMobService - Updated state: _isAdLoaded=$_isAdLoaded',
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('DEBUG: AdMobService - ❌ Failed to load rewarded ad!');
            print('DEBUG: AdMobService - Error code: ${error.code}');
            print('DEBUG: AdMobService - Error domain: ${error.domain}');
            print('DEBUG: AdMobService - Error message: ${error.message}');
            print('DEBUG: AdMobService - Full error: $error');
            _isAdLoaded = false;
            _rewardedAd = null;
          },
        ),
      );
      print('DEBUG: AdMobService - RewardedAd.load() call completed');
    } catch (e) {
      print('DEBUG: AdMobService - ❌ Exception during ad loading: $e');
      _isAdLoaded = false;
      _rewardedAd = null;
    }
  }

  Future<bool> showRewardedAd() async {
    print('DEBUG: AdMobService - showRewardedAd called');
    print(
      'DEBUG: AdMobService - Current state: _isAdLoaded=$_isAdLoaded, _rewardedAd=$_rewardedAd',
    );

    if (!_isAdLoaded || _rewardedAd == null) {
      print('DEBUG: AdMobService - ❌ Cannot show ad - not loaded or null');
      print('DEBUG: AdMobService - _isAdLoaded: $_isAdLoaded');
      print('DEBUG: AdMobService - _rewardedAd: $_rewardedAd');
      return false;
    }

    print('DEBUG: AdMobService - ✅ Ad is ready to show');

    // Use a Completer to properly wait for ad completion
    final Completer<bool> adCompleter = Completer<bool>();
    bool adWatched = false;

    print('DEBUG: AdMobService - Setting up fullScreenContentCallback...');
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        print('DEBUG: AdMobService - 📺 Ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('DEBUG: AdMobService - 🔙 Rewarded ad dismissed');
        print('DEBUG: AdMobService - User earned reward: $adWatched');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        print('DEBUG: AdMobService - Ad disposed, loading next ad...');

        // Complete the future with the result
        if (!adCompleter.isCompleted) {
          adCompleter.complete(adWatched);
        }

        // Preload the next ad
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('DEBUG: AdMobService - ❌ Failed to show rewarded ad full screen');
        print('DEBUG: AdMobService - Error code: ${error.code}');
        print('DEBUG: AdMobService - Error message: ${error.message}');
        print('DEBUG: AdMobService - Full error: $error');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;

        // Complete the future with failure
        if (!adCompleter.isCompleted) {
          adCompleter.complete(false);
        }

        // Preload the next ad
        loadRewardedAd();
      },
      onAdClicked: (RewardedAd ad) {
        print('DEBUG: AdMobService - 👆 Ad was clicked');
      },
    );

    try {
      print('DEBUG: AdMobService - Calling show() on rewarded ad...');
      // Show the ad and set up reward callback
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('DEBUG: AdMobService - 🎉 User earned reward!');
          print('DEBUG: AdMobService - Reward amount: ${reward.amount}');
          print('DEBUG: AdMobService - Reward type: ${reward.type}');
          adWatched = true;
        },
      );
      print(
        'DEBUG: AdMobService - show() call completed, waiting for ad completion...',
      );

      // Wait for the ad to be dismissed to know the final result
      final result = await adCompleter.future;
      print('DEBUG: AdMobService - Ad completed with result: $result');
      return result;
    } catch (e) {
      print('DEBUG: AdMobService - ❌ Exception during ad show: $e');
      if (!adCompleter.isCompleted) {
        adCompleter.complete(false);
      }
      return false;
    }
  }

  void dispose() {
    print('DEBUG: AdMobService - dispose() called');
    print(
      'DEBUG: AdMobService - Current state before dispose: _isAdLoaded=$_isAdLoaded, _rewardedAd=$_rewardedAd',
    );
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;
    print('DEBUG: AdMobService - dispose() completed');
  }
}
