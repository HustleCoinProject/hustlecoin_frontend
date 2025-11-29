import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AdMobService {
  // Rewarded Ad IDs
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917'; // Test ad unit
  static const String _rewardedAdUnitId =
      'ca-app-pub-3737974260376908/7706125192'; // Your actual ad unit

  // Banner Ad IDs
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // Test banner ad unit
  static const String _bannerAdUnitId =
      'ca-app-pub-3737974260376908/1994649425'; // Your actual banner ad unit

  // Interstitial Ad IDs
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // Test interstitial ad unit
  static const String _interstitialAdUnitId =
      'ca-app-pub-3737974260376908/6009900147'; // Your actual interstitial ad unit

  // App Open Ad IDs
  static const String _testAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/3419835294'; // Test app open ad unit
  static const String _appOpenAdUnitId =
      'ca-app-pub-3737974260376908/4122103406'; // Your actual app open ad unit

  // Use test ad in debug mode, real ad in release mode
  static String get rewardedAdUnitId {
    final id = kDebugMode ? _testRewardedAdUnitId : _rewardedAdUnitId;
    print(
      'DEBUG: AdMobService - Using rewarded ad unit ID: $id (Debug mode: $kDebugMode, Release mode: ${!kDebugMode})',
    );
    // Additional validation for release mode
    if (!kDebugMode && id == _rewardedAdUnitId) {
      print('DEBUG: AdMobService - ✅ Using PRODUCTION rewarded ad unit ID');
    }
    return id;
  }

  static String get bannerAdUnitId {
    final id = kDebugMode ? _testBannerAdUnitId : _bannerAdUnitId;
    print(
      'DEBUG: AdMobService - Using banner ad unit ID: $id (Debug mode: $kDebugMode)',
    );
    return id;
  }

  static String get interstitialAdUnitId {
    final id = kDebugMode ? _testInterstitialAdUnitId : _interstitialAdUnitId;
    print(
      'DEBUG: AdMobService - Using interstitial ad unit ID: $id (Debug mode: $kDebugMode)',
    );
    return id;
  }

  static String get appOpenAdUnitId {
    final id = kDebugMode ? _testAppOpenAdUnitId : _appOpenAdUnitId;
    print(
      'DEBUG: AdMobService - Using app open ad unit ID: $id (Debug mode: $kDebugMode)',
    );
    return id;
  }

  // Ad instances
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;

  // Ad states
  bool _isRewardedAdLoaded = false;
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isAppOpenAdLoaded = false;

  // App lifecycle management for app open ads
  DateTime? _appOpenAdLastShown;
  static const Duration _appOpenAdCooldown = Duration(
    hours: 4,
  ); // Show app open ad max once every 4 hours

  // Singleton pattern
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Getters for ad states
  bool get isRewardedAdLoaded {
    print(
      'DEBUG: AdMobService - isRewardedAdLoaded called, current state: $_isRewardedAdLoaded',
    );
    return _isRewardedAdLoaded;
  }

  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isAppOpenAdLoaded => _isAppOpenAdLoaded;

  // Legacy getter for backward compatibility
  bool get isAdLoaded => isRewardedAdLoaded;

  Future<void> loadRewardedAd() async {
    print('DEBUG: AdMobService - Starting to load rewarded ad...');
    print(
      'DEBUG: AdMobService - Current ad state before loading: _isRewardedAdLoaded=$_isRewardedAdLoaded, _rewardedAd=$_rewardedAd',
    );

    final currentAdUnitId = rewardedAdUnitId;
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
            _isRewardedAdLoaded = true;
            print(
              'DEBUG: AdMobService - Updated state: _isRewardedAdLoaded=$_isRewardedAdLoaded',
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('DEBUG: AdMobService - ❌ Failed to load rewarded ad!');
            print('DEBUG: AdMobService - Error code: ${error.code}');
            print('DEBUG: AdMobService - Error domain: ${error.domain}');
            print('DEBUG: AdMobService - Error message: ${error.message}');
            print('DEBUG: AdMobService - Full error: $error');
            print('DEBUG: AdMobService - Ad Unit ID used: ${rewardedAdUnitId}');
            print('DEBUG: AdMobService - kDebugMode: $kDebugMode');
            
            // Common error codes and their meanings:
            // 0 = ERROR_CODE_INTERNAL_ERROR
            // 1 = ERROR_CODE_INVALID_REQUEST  
            // 2 = ERROR_CODE_NETWORK_ERROR
            // 3 = ERROR_CODE_NO_FILL
            if (error.code == 1) {
              print('DEBUG: AdMobService - ⚠️ INVALID_REQUEST - Check ad unit ID and app configuration');
            } else if (error.code == 2) {
              print('DEBUG: AdMobService - ⚠️ NETWORK_ERROR - Check internet connection and permissions');
            } else if (error.code == 3) {
              print('DEBUG: AdMobService - ⚠️ NO_FILL - No ad inventory available (common in production)');
            }
            
            _isRewardedAdLoaded = false;
            _rewardedAd = null;
          },
        ),
      );
      print('DEBUG: AdMobService - RewardedAd.load() call completed');
    } catch (e) {
      print('DEBUG: AdMobService - ❌ Exception during ad loading: $e');
      _isRewardedAdLoaded = false;
      _rewardedAd = null;
    }
  }

  Future<bool> showRewardedAd() async {
    print('DEBUG: AdMobService - showRewardedAd called');
    print(
      'DEBUG: AdMobService - Current state: _isRewardedAdLoaded=$_isRewardedAdLoaded, _rewardedAd=$_rewardedAd',
    );

    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      print('DEBUG: AdMobService - ❌ Cannot show ad - not loaded or null');
      print('DEBUG: AdMobService - _isRewardedAdLoaded: $_isRewardedAdLoaded');
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
        _isRewardedAdLoaded = false;
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
        _isRewardedAdLoaded = false;

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

  // ========== BANNER AD METHODS ==========
  Future<BannerAd?> loadBannerAd() async {
    print('DEBUG: AdMobService - Starting to load banner ad...');

    try {
      final bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('DEBUG: AdMobService - ✅ Banner ad loaded successfully!');
            _bannerAd = ad as BannerAd;
            _isBannerAdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            print('DEBUG: AdMobService - ❌ Failed to load banner ad!');
            print('DEBUG: AdMobService - Error: $error');
            ad.dispose();
            _isBannerAdLoaded = false;
            _bannerAd = null;
          },
          onAdOpened: (ad) {
            print('DEBUG: AdMobService - Banner ad opened');
          },
          onAdClosed: (ad) {
            print('DEBUG: AdMobService - Banner ad closed');
          },
        ),
      );

      await bannerAd.load();
      return bannerAd;
    } catch (e) {
      print('DEBUG: AdMobService - ❌ Exception during banner ad loading: $e');
      _isBannerAdLoaded = false;
      _bannerAd = null;
      return null;
    }
  }

  void disposeBannerAd() {
    print('DEBUG: AdMobService - Disposing banner ad');
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  // ========== INTERSTITIAL AD METHODS ==========
  Future<void> loadInterstitialAd() async {
    print('DEBUG: AdMobService - Starting to load interstitial ad...');

    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            print(
              'DEBUG: AdMobService - ✅ Interstitial ad loaded successfully!',
            );
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;

            // Set up full screen content callback
            _interstitialAd!
                .fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                print(
                  'DEBUG: AdMobService - Interstitial ad showed full screen',
                );
              },
              onAdDismissedFullScreenContent: (ad) {
                print('DEBUG: AdMobService - Interstitial ad dismissed');
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoaded = false;
                // Preload next interstitial ad
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print(
                  'DEBUG: AdMobService - ❌ Failed to show interstitial ad: $error',
                );
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoaded = false;
                // Preload next interstitial ad
                loadInterstitialAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('DEBUG: AdMobService - ❌ Failed to load interstitial ad!');
            print('DEBUG: AdMobService - Error: $error');
            _isInterstitialAdLoaded = false;
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      print(
        'DEBUG: AdMobService - ❌ Exception during interstitial ad loading: $e',
      );
      _isInterstitialAdLoaded = false;
      _interstitialAd = null;
    }
  }

  Future<bool> showInterstitialAd() async {
    print('DEBUG: AdMobService - showInterstitialAd called');
    print(
      'DEBUG: AdMobService - Interstitial ad loaded: $_isInterstitialAdLoaded',
    );

    if (!_isInterstitialAdLoaded || _interstitialAd == null) {
      print('DEBUG: AdMobService - ❌ Cannot show interstitial ad - not loaded');
      return false;
    }

    try {
      await _interstitialAd!.show();
      print('DEBUG: AdMobService - ✅ Interstitial ad shown successfully');
      return true;
    } catch (e) {
      print('DEBUG: AdMobService - ❌ Exception showing interstitial ad: $e');
      return false;
    }
  }

  // ========== APP OPEN AD METHODS ==========
  Future<void> loadAppOpenAd() async {
    print('DEBUG: AdMobService - Starting to load app open ad...');

    try {
      await AppOpenAd.load(
        adUnitId: appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            print('DEBUG: AdMobService - ✅ App open ad loaded successfully!');
            _appOpenAd = ad;
            _isAppOpenAdLoaded = true;

            // Set up full screen content callback
            _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                print('DEBUG: AdMobService - App open ad showed full screen');
                _appOpenAdLastShown = DateTime.now();
              },
              onAdDismissedFullScreenContent: (ad) {
                print('DEBUG: AdMobService - App open ad dismissed');
                ad.dispose();
                _appOpenAd = null;
                _isAppOpenAdLoaded = false;
                // Preload next app open ad
                loadAppOpenAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print(
                  'DEBUG: AdMobService - ❌ Failed to show app open ad: $error',
                );
                ad.dispose();
                _appOpenAd = null;
                _isAppOpenAdLoaded = false;
                // Preload next app open ad
                loadAppOpenAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('DEBUG: AdMobService - ❌ Failed to load app open ad!');
            print('DEBUG: AdMobService - Error: $error');
            _isAppOpenAdLoaded = false;
            _appOpenAd = null;
          },
        ),
      );
    } catch (e) {
      print('DEBUG: AdMobService - ❌ Exception during app open ad loading: $e');
      _isAppOpenAdLoaded = false;
      _appOpenAd = null;
    }
  }

  Future<bool> showAppOpenAd() async {
    print('DEBUG: AdMobService - showAppOpenAd called');

    // Check cooldown
    if (_appOpenAdLastShown != null) {
      final timeSinceLastShown = DateTime.now().difference(
        _appOpenAdLastShown!,
      );
      if (timeSinceLastShown < _appOpenAdCooldown) {
        print(
          'DEBUG: AdMobService - App open ad on cooldown for ${_appOpenAdCooldown - timeSinceLastShown}',
        );
        return false;
      }
    }

    if (!_isAppOpenAdLoaded || _appOpenAd == null) {
      print('DEBUG: AdMobService - ❌ Cannot show app open ad - not loaded');
      return false;
    }

    try {
      await _appOpenAd!.show();
      print('DEBUG: AdMobService - ✅ App open ad shown successfully');
      return true;
    } catch (e) {
      print('DEBUG: AdMobService - ❌ Exception showing app open ad: $e');
      return false;
    }
  }

  bool get canShowAppOpenAd {
    if (_appOpenAdLastShown == null) return true;

    final timeSinceLastShown = DateTime.now().difference(_appOpenAdLastShown!);
    return timeSinceLastShown >= _appOpenAdCooldown;
  }

  /// Test method to validate ad unit IDs and configuration
  static void validateAdConfiguration() {
    print('=== VALIDATING ADMOB CONFIGURATION ===');
    print('App ID: ca-app-pub-3737974260376908~8839259376');
    print('Package Name Expected: com.example.hustlecoin (verify this matches AdMob console)');
    print('');
    
    print('Production Ad Unit IDs:');
    print('- Rewarded: $_rewardedAdUnitId');
    print('- Banner: $_bannerAdUnitId');
    print('- Interstitial: $_interstitialAdUnitId');
    print('- App Open: $_appOpenAdUnitId');
    print('');
    
    print('Test Ad Unit IDs:');
    print('- Rewarded: $_testRewardedAdUnitId');
    print('- Banner: $_testBannerAdUnitId');
    print('- Interstitial: $_testInterstitialAdUnitId');
    print('- App Open: $_testAppOpenAdUnitId');
    print('');
    
    print('Current Mode: ${kDebugMode ? "DEBUG (using test ads)" : "RELEASE (using production ads)"}');
    print('=== END VALIDATION ===');
  }

  void dispose() {
    print('DEBUG: AdMobService - dispose() called');
    print(
      'DEBUG: AdMobService - Current state before dispose: _isRewardedAdLoaded=$_isRewardedAdLoaded, _rewardedAd=$_rewardedAd',
    );

    // Dispose all ads
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdLoaded = false;

    disposeBannerAd();

    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdLoaded = false;

    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAppOpenAdLoaded = false;

    print('DEBUG: AdMobService - dispose() completed');
  }
}
