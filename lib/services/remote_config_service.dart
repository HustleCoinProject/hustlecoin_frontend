import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Keys
  static const String _keyLandResolution = 'H3_TILE_INDEX_RESOLUTION';
  static const String _keyLandBuyPrice = 'LAND_BUY_PRICE';
  static const String _keyLandSellPrice = 'LAND_SELL_PRICE';
  static const String _keyHcToKzRate = 'HC_TO_KZ_RATE';

  // Default Values
  static const int _defaultLandResolution = 8;
  static const int _defaultLandBuyPrice = 500;
  static const int _defaultLandSellPrice = 400;
  static const int _defaultHcToKzRate = 20;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 12),
        ),
      );

      await _remoteConfig.setDefaults({
        _keyLandResolution: _defaultLandResolution,
        _keyLandBuyPrice: _defaultLandBuyPrice,
        _keyLandSellPrice: _defaultLandSellPrice,
        _keyHcToKzRate: _defaultHcToKzRate,
      });

      await _fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config initialization failed: $e');
    }
  }

  Future<void> _fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
      debugPrint('Remote Config fetched and activated');
    } catch (e) {
      debugPrint('Remote Config fetch failed: $e');
    }
  }

  // Getters
  int getLandResolution() {
    return _remoteConfig.getInt(_keyLandResolution);
  }

  int getLandBuyPrice() {
    return _remoteConfig.getInt(_keyLandBuyPrice);
  }

  int getLandSellPrice() {
    return _remoteConfig.getInt(_keyLandSellPrice);
  }

  double getHcToKzRate() {
    // Return default if key doesn't exist or is 0 (to prevent division by zero)
    final val = _remoteConfig.getDouble(_keyHcToKzRate);
    return val > 0 ? val : _defaultHcToKzRate.toDouble();
  }
}
