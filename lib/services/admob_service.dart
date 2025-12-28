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
    // Additional validation for release mode
    return id;
  }

  static String get bannerAdUnitId {
    final id = kDebugMode ? _testBannerAdUnitId : _bannerAdUnitId;
    return id;
  }

  static String get interstitialAdUnitId {
    final id = kDebugMode ? _testInterstitialAdUnitId : _interstitialAdUnitId;
    return id;
  }

  static String get appOpenAdUnitId {
    final id = kDebugMode ? _testAppOpenAdUnitId : _appOpenAdUnitId;
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

  // Singleton pattern
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal() {
    _appStartTime = DateTime.now();
  }

  // App lifecycle management for app open ads
  DateTime? _appOpenAdLastShown;
  static const Duration _appOpenAdCooldown = Duration(
    hours: 4,
  ); // Show app open ad max once every 4 hours

  // Interstitial Ad Management
  DateTime? _interstitialLastShown;
  late final DateTime _appStartTime;

  // OPTIMIZED SETTINGS:
  // 1. Session Start Grace Period: No ads for first 90 seconds
  static const Duration _sessionStartGracePeriod = Duration(seconds: 90);
  // 2. Frequency Cap: Minimum 4 minutes between interstitial ads
  static const Duration _interstitialCooldown = Duration(minutes: 4);

  // Getters for ad states
  bool get isRewardedAdLoaded {
    return _isRewardedAdLoaded;
  }

  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isAppOpenAdLoaded => _isAppOpenAdLoaded;

  // Legacy getter for backward compatibility
  bool get isAdLoaded => isRewardedAdLoaded;

  Future<void> loadRewardedAd() async {
    final currentAdUnitId = rewardedAdUnitId;

    try {
      await RewardedAd.load(
        adUnitId: currentAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;
          },
          onAdFailedToLoad: (LoadAdError error) {
            // Common error codes and their meanings:
            // 0 = ERROR_CODE_INTERNAL_ERROR
            // 1 = ERROR_CODE_INVALID_REQUEST
            // 2 = ERROR_CODE_NETWORK_ERROR
            // 3 = ERROR_CODE_NO_FILL

            _isRewardedAdLoaded = false;
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      _isRewardedAdLoaded = false;
      _rewardedAd = null;
    }
  }

  Future<bool> showRewardedAd() async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      return false;
    }

    // Use a Completer to properly wait for ad completion
    final Completer<bool> adCompleter = Completer<bool>();
    bool adWatched = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {},
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;

        // Complete the future with the result
        if (!adCompleter.isCompleted) {
          adCompleter.complete(adWatched);
        }

        // Preload the next ad
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
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
      onAdClicked: (RewardedAd ad) {},
    );

    try {
      // Show the ad and set up reward callback
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          adWatched = true;
        },
      );

      // Wait for the ad to be dismissed to know the final result
      final result = await adCompleter.future;
      return result;
    } catch (e) {
      if (!adCompleter.isCompleted) {
        adCompleter.complete(false);
      }
      return false;
    }
  }

  // ========== BANNER AD METHODS ==========
  Future<BannerAd?> loadBannerAd() async {
    try {
      final bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _bannerAd = ad as BannerAd;
            _isBannerAdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _isBannerAdLoaded = false;
            _bannerAd = null;
          },
          onAdOpened: (ad) {},
          onAdClosed: (ad) {},
        ),
      );

      await bannerAd.load();
      return bannerAd;
    } catch (e) {
      _isBannerAdLoaded = false;
      _bannerAd = null;
      return null;
    }
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  // ========== INTERSTITIAL AD METHODS ==========
  Future<void> loadInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;

            // Set up full screen content callback
            _interstitialAd!.fullScreenContentCallback =
                FullScreenContentCallback(
                  onAdShowedFullScreenContent: (ad) {
                    // Mark time when ad is shown
                    _interstitialLastShown = DateTime.now();
                  },
                  onAdDismissedFullScreenContent: (ad) {
                    ad.dispose();
                    _interstitialAd = null;
                    _isInterstitialAdLoaded = false;
                    // Preload next interstitial ad
                    loadInterstitialAd();
                  },
                  onAdFailedToShowFullScreenContent: (ad, error) {
                    ad.dispose();
                    _interstitialAd = null;
                    _isInterstitialAdLoaded = false;
                    // Preload next interstitial ad
                    loadInterstitialAd();
                  },
                );
          },
          onAdFailedToLoad: (error) {
            _isInterstitialAdLoaded = false;
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      _isInterstitialAdLoaded = false;
      _interstitialAd = null;
    }
  }

  Future<bool> showInterstitialAd() async {
    // 1. Check Grace Period
    if (DateTime.now().difference(_appStartTime) < _sessionStartGracePeriod) {
      debugPrint('Ad skipped: Still in session grace period');
      return false;
    }

    // 2. Check Cooldown
    if (_interstitialLastShown != null) {
      final difference = DateTime.now().difference(_interstitialLastShown!);
      if (difference < _interstitialCooldown) {
        debugPrint(
          'Ad skipped: In cooldown (${difference.inMinutes} mins since last)',
        );
        return false;
      }
    }

    if (!_isInterstitialAdLoaded || _interstitialAd == null) {
      // Try to load for next time if it wasn't loaded
      loadInterstitialAd();
      return false;
    }

    try {
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== APP OPEN AD METHODS ==========
  Future<void> loadAppOpenAd() async {
    try {
      await AppOpenAd.load(
        adUnitId: appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            _isAppOpenAdLoaded = true;

            // Set up full screen content callback
            _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                _appOpenAdLastShown = DateTime.now();
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _appOpenAd = null;
                _isAppOpenAdLoaded = false;
                // Preload next app open ad
                loadAppOpenAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _appOpenAd = null;
                _isAppOpenAdLoaded = false;
                // Preload next app open ad
                loadAppOpenAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            _isAppOpenAdLoaded = false;
            _appOpenAd = null;
          },
        ),
      );
    } catch (e) {
      _isAppOpenAdLoaded = false;
      _appOpenAd = null;
    }
  }

  Future<bool> showAppOpenAd() async {
    // Check cooldown
    if (_appOpenAdLastShown != null) {
      final timeSinceLastShown = DateTime.now().difference(
        _appOpenAdLastShown!,
      );
      if (timeSinceLastShown < _appOpenAdCooldown) {
        return false;
      }
    }

    if (!_isAppOpenAdLoaded || _appOpenAd == null) {
      return false;
    }

    try {
      await _appOpenAd!.show();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool get canShowAppOpenAd {
    if (_appOpenAdLastShown == null) return true;

    final timeSinceLastShown = DateTime.now().difference(_appOpenAdLastShown!);
    return timeSinceLastShown >= _appOpenAdCooldown;
  }

  /// Test method to validate ad unit IDs and configuration
  static void validateAdConfiguration() {}

  void dispose() {
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
  }
}
