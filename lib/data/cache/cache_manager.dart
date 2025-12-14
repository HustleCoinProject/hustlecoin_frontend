import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'cache_entry.dart';

/// Manages caching operations with TTL support using Hive
/// Stores all data as JSON strings to avoid type registration issues
class CacheManager {
  static const String _boxName = 'api_cache';
  Box<dynamic>? _box;

  /// Initialize the cache manager
  Future<void> initialize() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<dynamic>(_boxName);
    }
  }

  /// Get cached data by key
  /// Returns null if cache doesn't exist or has expired
  /// Automatically decodes JSON strings back to objects
  Future<T?> get<T>(String key) async {
    await initialize();

    try {
      final rawData = _box!.get(key);
      if (rawData == null) {
        return null;
      }

      // Deserialize the cache entry
      final cacheData = rawData as Map<dynamic, dynamic>;
      final lastFetched = DateTime.parse(cacheData['lastFetched'] as String);
      final ttlSeconds = cacheData['ttl'] as int;
      final ttl = Duration(seconds: ttlSeconds);

      final cacheEntry = CacheEntry<T>(
        key: key,
        data: cacheData['data'],
        lastFetched: lastFetched,
        ttl: ttl,
      );

      if (cacheEntry.isExpired) {
        await delete(key); // Clean up expired cache
        return null;
      }

      
      // Decode JSON string back to object
      final jsonData = cacheEntry.data as String;
      final decoded = json.decode(jsonData);
      return decoded as T;
    } catch (e) {
      return null;
    }
  }

  /// Store data in cache with TTL
  /// Converts data to JSON string for storage
  Future<void> set<T>(String key, T data, Duration ttl) async {
    await initialize();

    try {
      // Convert data to JSON string to avoid Hive type registration issues
      String jsonData;
      if (data is String) {
        jsonData = data;
      } else if (data is List || data is Map) {
        jsonData = json.encode(data);
      } else {
        // For other types, try to encode directly
        jsonData = json.encode(data);
      }

      final cacheEntry = {
        'key': key,
        'data': jsonData,
        'lastFetched': DateTime.now().toIso8601String(),
        'ttl': ttl.inSeconds,
      };

      await _box!.put(key, cacheEntry);
    } catch (e) {
    }
  }

  /// Delete cached data by key
  Future<void> delete(String key) async {
    await initialize();
    await _box!.delete(key);
  }

  /// Clear all cached data
  Future<void> clear() async {
    await initialize();
    await _box!.clear();
  }

  /// Check if cache exists and is valid
  Future<bool> hasValid(String key) async {
    final data = await get(key);
    return data != null;
  }

  /// Get all cached keys
  Future<List<String>> getAllKeys() async {
    await initialize();
    return _box!.keys.cast<String>().toList();
  }

  /// Close the cache box
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
  }
}
