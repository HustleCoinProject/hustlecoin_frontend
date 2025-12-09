
/// A generic cache entry that stores data with TTL (Time To Live)
class CacheEntry<T> {
  final String key;
  final dynamic data;
  final DateTime lastFetched;
  final Duration ttl;

  CacheEntry({
    required this.key,
    required this.data,
    required this.lastFetched,
    required this.ttl,
  });

  /// Check if this cache entry has expired
  bool get isExpired {
    final now = DateTime.now();
    return now.difference(lastFetched) > ttl;
  }

  /// Check if this cache entry is still valid
  bool get isValid => !isExpired;

  /// Time remaining until expiration
  Duration get timeRemaining {
    final expiryTime = lastFetched.add(ttl);
    final now = DateTime.now();
    final remaining = expiryTime.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Create a copy with updated data and timestamp
  CacheEntry<T> copyWith({
    String? key,
    dynamic data,
    DateTime? lastFetched,
    Duration? ttl,
  }) {
    return CacheEntry<T>(
      key: key ?? this.key,
      data: data ?? this.data,
      lastFetched: lastFetched ?? this.lastFetched,
      ttl: ttl ?? this.ttl,
    );
  }
}
