import '../models/auth_tokens.dart';
import '../models/user.dart';
import '../models/level_status.dart';
import '../models/inventory_item_out.dart';
import '../models/task.dart';
import '../models/shop_item.dart';
import '../models/leaderboard_entry.dart';
import '../models/quiz_question.dart';
import '../models/land_tile_info.dart';
import '../models/my_land_tiles.dart';
import '../models/land_claim_status.dart';
import '../models/land_claim_response.dart';
import '../models/tap_response.dart';
import '../models/payout.dart';
import '../models/payout_info.dart';
import '../models/payout_request.dart';
import '../models/task_completion_response.dart';
import '../models/land_purchase_response.dart';
import '../models/tapping_status.dart';
import '../models/safe_lock_status.dart';
import '../models/safe_lock_deposit_response.dart';
import '../models/safe_lock_claim_response.dart';
import '../models/safe_lock_global_stats.dart';
import '../cache/cache_manager.dart';
import 'api_repository.dart';

/// DataRepository acts as an intermediary between the UI and ApiRepository
/// It manages caching with TTL to reduce unnecessary API calls
class DataRepository {
  final ApiRepository _apiRepository;
  final CacheManager _cacheManager;

  // Cache TTL configurations (in minutes)
  static const Duration _defaultTTL = Duration(
    minutes: 5,
  ); // Payout methods, payout system status
  static const Duration _userTTL = Duration(
    minutes: 5,
  ); // /api/users/me - User profile data
  static const Duration _inventoryTTL = Duration(
    minutes: 5,
  ); // /api/users/inventory - User items
  static const Duration _hustlesTTL = Duration(
    days: 7,
  ); // /api/hustles/all, /api/hustles/available - Hustle lists
  static const Duration _levelStatusTTL = Duration(
    minutes: 30,
  ); // /api/hustles/level-status - Level progress
  static const Duration _tasksTTL = Duration(
    days: 7,
  ); // /api/tasks/all - Task list
  static const Duration _shopTTL = Duration(
    days: 7,
  ); // /api/shop/items - Shop items
  static const Duration _leaderboardTTL = Duration(
    minutes: 8,
  ); // /api/leaderboard - Rankings
  // Note: Land tiles (/api/land/tiles) are NOT cached - UI implements 3-second rate limiting
  static const Duration _myLandsTTL = Duration(
    minutes: 5,
  ); // /api/land/my-lands - Owned lands
  static const Duration _landClaimStatusTTL = Duration(
    minutes: 5,
  ); // /api/land/claim-status - Land income status
  static const Duration _tappingStatusTTL = Duration(
    seconds: 30,
  ); // /api/tapping/status - Tap limits & earnings
  static const Duration _payoutInfoTTL = Duration(
    minutes: 10,
  ); // /api/payouts/info - Payout account info
  static const Duration _payoutHistoryTTL = Duration(
    minutes: 10,
  ); // /api/payouts/history - Past payouts
  static const Duration _safeLockStatusTTL = Duration(
    minutes: 10,
  ); // /api/safe-lock/status - Safe lock balance & timer
  static const Duration _safeLockGlobalStatsTTL = Duration(
    minutes: 10,
  ); // /api/safe-lock/global-stats - Global safe lock stats

  DataRepository(this._apiRepository, this._cacheManager);

  void setTokens(String? accessToken, String? refreshToken) {
    _apiRepository.setTokens(accessToken, refreshToken);
  }

  void setOnTokensRefreshed(Function(AuthTokens)? callback) {
    _apiRepository.setOnTokensRefreshed(callback);
  }

  // Helper method to get cached or fetch from API
  // Note: T must be a type that can be JSON serialized/deserialized
  Future<T> _getOrFetch<T>(
    String cacheKey,
    Future<T> Function() fetchFunction,
    Duration ttl, {
    T Function(dynamic)? fromJson,
    dynamic Function(T)? toJson,
  }) async {
    // Try to get from cache first
    try {
      final cached = await _cacheManager.get<dynamic>(cacheKey);
      if (cached != null) {
        // If a converter is provided, use it to deserialize
        if (fromJson != null) {
          return fromJson(cached);
        }
        // Otherwise, cast directly
        return cached as T;
      }
    } catch (e) {}

    // Cache miss or expired, fetch from API
    final data = await fetchFunction();

    // Convert to JSON-serializable format before caching if converter provided
    final cacheData = toJson != null ? toJson(data) : data;

    // Store in cache (will be JSON encoded by CacheManager)
    await _cacheManager.set(cacheKey, cacheData, ttl);

    return data;
  }

  // --- Auth ---
  Future<AuthTokens> login(String username, String password) async {
    // Login should always hit the server, never cached
    final tokens = await _apiRepository.login(username, password);
    // Clear all cache on new login
    await _cacheManager.clear();
    return tokens;
  }

  Future<AuthTokens> loginWithFirebase(String firebaseIdToken) async {
    // Firebase login should always hit the server, never cached
    final tokens = await _apiRepository.loginWithFirebase(firebaseIdToken);
    // Clear all cache on new login
    await _cacheManager.clear();
    return tokens;
  }

  Future<User> register(
    String email,
    String password,
    String username,
    String hustleKey,
    String lang,
  ) async {
    // Registration should always hit the server
    return await _apiRepository.register(
      email,
      password,
      username,
      hustleKey,
      lang,
    );
  }

  // --- User ---
  Future<User> getMe() async {
    return await _getOrFetch(
      'user_me',
      () => _apiRepository.getMe(),
      _userTTL,
      fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
      toJson: (user) => {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'hc_balance': user.hcBalance,
        // 'kz_balance': user.kzBalance, // Removed
        'rank_points': user.rankPoints,
        'level': user.level,
        'current_hustle': user.currentHustle,
        'level_entry_date': user.levelEntryDate.toIso8601String(),
        'hc_earned_in_level': user.hcEarnedInLevel,
        'language': user.language,
        'task_cooldowns': user.taskCooldowns,
        'daily_streak': user.dailyStreak,
        'created_at': user.createdAt.toIso8601String(),
        'daily_tap_earnings': user.dailyTapEarnings,
        'last_tap_reset_date': user.lastTapResetDate?.toIso8601String(),
        'phone_number': user.phoneNumber,
        'full_name': user.fullName,
        'national_id': user.nationalId,
        'bank_iban': user.bankIban,
        'bank_name': user.bankName,
      },
    );
  }

  Future<void> updateProfile({
    String? email,
    String? currentPassword,
    String? newPassword,
    String? language,
    String? currentHustle,
  }) async {
    await _apiRepository.updateProfile(
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
      language: language,
      currentHustle: currentHustle,
    );
    // Invalidate user cache after profile update
    await _cacheManager.delete('user_me');
  }

  Future<List<InventoryItemOut>> getInventory() async {
    return await _getOrFetch(
      'user_inventory',
      () => _apiRepository.getInventory(),
      _inventoryTTL,
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map(
              (item) => InventoryItemOut.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      },
      toJson: (items) => items
          .map(
            (item) => {
              'item_id': item.itemId,
              'quantity': item.quantity,
              'name': item.name,
              'description': item.description,
              'item_type': item.itemType,
            },
          )
          .toList(),
    );
  }

  // --- Hustles & Levels ---
  Future<Map<String, Map<String, String>>> getAllHustles() async {
    return await _getOrFetch(
      'hustles_all',
      () => _apiRepository.getAllHustles(),
      _hustlesTTL,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return map.map(
          (key, value) => MapEntry(key, Map<String, String>.from(value as Map)),
        );
      },
    );
  }

  Future<Map<String, String>> getAvailableHustles() async {
    return await _getOrFetch(
      'hustles_available',
      () => _apiRepository.getAvailableHustles(),
      _hustlesTTL,
      fromJson: (json) => Map<String, String>.from(json as Map),
    );
  }

  Future<LevelStatus> getLevelStatus() async {
    return await _getOrFetch(
      'level_status',
      () => _apiRepository.getLevelStatus(),
      _levelStatusTTL,
      fromJson: (json) => LevelStatus.fromJson(json as Map<String, dynamic>),
      toJson: (status) => {
        'current_level': status.currentLevel,
        'current_hustle': status.currentHustle,
        'days_in_level_progress': status.daysInLevelProgress,
        'days_in_level_required': status.daysInLevelRequired,
        'hc_earned_in_level_progress': status.hcEarnedInLevelProgress,
        'hc_earned_in_level_required': status.hcEarnedInLevelRequired,
        'upgrade_fee': status.upgradeFee,
        'is_eligible_for_upgrade': status.isEligibleForUpgrade,
      },
    );
  }

  Future<Map<String, dynamic>> levelUpgrade() async {
    final result = await _apiRepository.levelUpgrade();
    // Invalidate related caches
    await _cacheManager.delete('level_status');
    await _cacheManager.delete('user_me');
    // Invalidate hustle lists as new level unlocks new hustles
    await _cacheManager.delete('hustles_available');
    await _cacheManager.delete('hustles_all');
    return result;
  }

  Future<void> selectHustle(String hustleKey) async {
    await _apiRepository.selectHustle(hustleKey);
    // Invalidate related caches
    await _cacheManager.delete('hustles_available');
    await _cacheManager.delete('user_me');
  }

  // --- Tasks & Shop ---
  Future<List<Task>> getAllTasks() async {
    return await _getOrFetch(
      'tasks_all',
      () => _apiRepository.getAllTasks(),
      _tasksTTL,
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map((item) => Task.fromJson(item as Map<String, dynamic>))
            .toList();
      },
      toJson: (tasks) => tasks
          .map(
            (task) => {
              'task_id': task.taskId,
              'description': task.description,
              'reward': task.reward,
              'rank_points': task.rankPoints,
              'type': task.type,
              'cooldown_seconds': task.cooldownSeconds,
            },
          )
          .toList(),
    );
  }

  Future<TaskCompletionResponse> completeTask(
    String taskId, {
    Map<String, dynamic>? payload,
  }) async {
    final result = await _apiRepository.completeTask(taskId, payload: payload);
    // Invalidate related caches
    // await _cacheManager.delete('tasks_all'); // THIS IS NOT RELATED IGUESS
    await _cacheManager.delete('user_me');
    return result;
  }

  Future<List<ShopItem>> getShopItems() async {
    return await _getOrFetch(
      'shop_items',
      () => _apiRepository.getShopItems(),
      _shopTTL,
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map((item) => ShopItem.fromJson(item as Map<String, dynamic>))
            .toList();
      },
      toJson: (items) => items
          .map(
            (item) => {
              'item_id': item.itemId,
              'name': item.name,
              'description': item.description,
              'price': item.price,
              'item_type': item.itemType,
              'metadata': item.metadata,
            },
          )
          .toList(),
    );
  }

  Future<void> purchaseItem(String itemId, int quantity) async {
    await _apiRepository.purchaseItem(itemId, quantity);
    // Invalidate related caches
    await _cacheManager.delete('shop_items');
    await _cacheManager.delete('user_inventory');
    await _cacheManager.delete('user_me');
  }

  // --- Server Time ---
  Future<DateTime> getServerTime() async {
    // Server time should always be fresh, never cached
    return await _apiRepository.getServerTime();
  }

  // --- Leaderboard ---
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    return await _getOrFetch(
      'leaderboard',
      () => _apiRepository.getLeaderboard(),
      _leaderboardTTL,
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map(
              (item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      },
      toJson: (entries) => entries
          .map(
            (entry) => {
              'username': entry.username,
              'rank_points': entry.rankPoints,
              'level': entry.level,
              'hc_balance': entry.hcBalance,
            },
          )
          .toList(),
    );
  }

  Future<QuizQuestion> fetchQuizQuestion() async {
    // Quiz questions should be fresh, not cached
    return await _apiRepository.fetchQuizQuestion();
  }

  // --- Land System ---
  Future<List<LandTileInfo>> getTilesInBbox(String bbox) async {
    // Land tiles are not cached - UI implements 3-second rate limiting
    // to prevent excessive requests while user moves the map
    return await _apiRepository.getTilesInBbox(bbox);
  }

  Future<List<MyLandTile>> getMyLands() async {
    return await _getOrFetch(
      'my_lands',
      () => _apiRepository.getMyLands(),
      _myLandsTTL,
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map((item) => MyLandTile.fromJson(item as Map<String, dynamic>))
            .toList();
      },
      toJson: (tiles) => tiles
          .map(
            (tile) => {
              'h3_index': tile.h3Index,
              'purchased_at': tile.purchasedAt.toIso8601String(),
              'purchase_price': tile.purchasePrice,
            },
          )
          .toList(),
    );
  }

  Future<LandPurchaseResponse> buyLandTile(String h3Index) async {
    final result = await _apiRepository.buyLandTile(h3Index);
    // Invalidate related caches
    await _cacheManager.delete('my_lands');
    await _cacheManager.delete('user_me');
    // Note: Land tiles are not cached, so no need to invalidate them
    return result;
  }

  Future<void> sellLandTile(String h3Index) async {
    await _apiRepository.sellLandTile(h3Index);
    // Invalidate related caches
    await _cacheManager.delete('my_lands');
    await _cacheManager.delete('user_me');
    // Note: Land tiles are not cached, so no need to invalidate them
  }

  // --- Land Income Claim System ---
  Future<LandClaimStatus> getLandClaimStatus() async {
    return await _getOrFetch(
      'land_claim_status',
      () => _apiRepository.getLandClaimStatus(),
      _landClaimStatusTTL,
      fromJson: (json) =>
          LandClaimStatus.fromJson(json as Map<String, dynamic>),
      toJson: (status) => status.toJson(),
    );
  }

  Future<LandClaimResponse> claimLandIncome() async {
    final result = await _apiRepository.claimLandIncome();
    // Invalidate related caches
    await _cacheManager.delete('land_claim_status');
    await _cacheManager.delete('user_me');
    return result;
  }

  // --- Tapping System ---
  Future<TappingStatus> getTappingStatus() async {
    return await _getOrFetch(
      'tapping_status',
      () => _apiRepository.getTappingStatus(),
      _tappingStatusTTL,
      fromJson: (json) => TappingStatus.fromJson(json as Map<String, dynamic>),
      toJson: (status) => {
        'daily_earnings': status.dailyEarnings,
        'daily_limit': status.dailyLimit,
        'remaining_taps': status.remainingTaps,
        'can_tap': status.canTap,
        'next_reset_at': status.nextResetAt?.toIso8601String(),
      },
    );
  }

  Future<TapResponse> submitTaps(int tapCount) async {
    final result = await _apiRepository.submitTaps(tapCount);
    // Invalidate related caches
    await _cacheManager.delete('tapping_status');
    await _cacheManager.delete('user_me');
    return result;
  }

  // --- Payout System ---
  Future<Map<String, dynamic>> getPayoutMethods() async {
    return await _getOrFetch(
      'payout_methods',
      () => _apiRepository.getPayoutMethods(),
      _defaultTTL,
    );
  }

  Future<PayoutInfo> getPayoutInfo() async {
    return await _getOrFetch(
      'payout_info',
      () => _apiRepository.getPayoutInfo(),
      _payoutInfoTTL,
      fromJson: (json) => PayoutInfo.fromJson(json as Map<String, dynamic>),
      toJson: (info) => {
        'available_balance_hc': info.availableHc,
        'conversion_rate': info.conversionRate,
        'min_payout_hc': info.minimumPayoutHc,
        'has_pending_payout': info.hasPendingPayout,
        'phone_number': info.phoneNumber,
        'full_name': info.fullName,
        'national_id': info.nationalId,
        'bank_iban': info.bankIban,
        'bank_name': info.bankName,
      },
    );
  }

  Future<void> updatePayoutInfo({
    String? phoneNumber,
    String? fullName,
    String? nationalId,
    String? bankIban,
    String? bankName,
  }) async {
    await _apiRepository.updatePayoutInfo(
      phoneNumber: phoneNumber,
      fullName: fullName,
      nationalId: nationalId,
      bankIban: bankIban,
      bankName: bankName,
    );
    // Invalidate payout info cache
    await _cacheManager.delete('payout_info');
  }

  Future<Payout> requestPayout(PayoutRequest payoutRequest) async {
    final result = await _apiRepository.requestPayout(payoutRequest);
    // Invalidate related caches
    await _cacheManager.delete('payout_info');
    await _cacheManager.delete('user_me');
    // Clear payout history cache
    final allKeys = await _cacheManager.getAllKeys();
    for (final key in allKeys) {
      if (key.startsWith('payout_history_')) {
        await _cacheManager.delete(key);
      }
    }
    return result;
  }

  Future<List<Payout>> getPayoutHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    return await _getOrFetch(
      'payout_history_${limit}_$offset',
      () => _apiRepository.getPayoutHistory(limit: limit, offset: offset),
      _payoutHistoryTTL,
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map((item) => Payout.fromJson(item as Map<String, dynamic>))
            .toList();
      },
      toJson: (payouts) => payouts.map((payout) => payout.toJson()).toList(),
    );
  }

  Future<Payout> getPayoutDetails(String payoutId) async {
    return await _getOrFetch(
      'payout_details_$payoutId',
      () => _apiRepository.getPayoutDetails(payoutId),
      _payoutHistoryTTL,
      fromJson: (json) => Payout.fromJson(json as Map<String, dynamic>),
      toJson: (payout) => payout.toJson(),
    );
  }

  Future<Map<String, dynamic>> getPayoutSystemStatus() async {
    return await _getOrFetch(
      'payout_system_status',
      () => _apiRepository.getPayoutSystemStatus(),
      _defaultTTL,
    );
  }

  // --- Safe Lock API Methods ---
  Future<SafeLockStatus> getSafeLockStatus() async {
    return await _getOrFetch(
      'safe_lock_status',
      () => _apiRepository.getSafeLockStatus(),
      _safeLockStatusTTL,
      fromJson: (json) => SafeLockStatus.fromJson(json as Map<String, dynamic>),
      toJson: (status) => status.toJson(),
    );
  }

  Future<SafeLockDepositResponse> depositToSafeLock(int amount) async {
    final result = await _apiRepository.depositToSafeLock(amount);
    // Invalidate related caches
    await _cacheManager.delete('safe_lock_status');
    await _cacheManager.delete('user_me');
    await _cacheManager.delete('safe_lock_global_stats');
    return result;
  }

  Future<SafeLockClaimResponse> claimSafeLock() async {
    final result = await _apiRepository.claimSafeLock();
    // Invalidate related caches
    await _cacheManager.delete('safe_lock_status');
    await _cacheManager.delete('user_me');
    await _cacheManager.delete('safe_lock_global_stats');
    return result;
  }

  Future<SafeLockGlobalStats> getSafeLockGlobalStats() async {
    return await _getOrFetch(
      'safe_lock_global_stats',
      () => _apiRepository.getSafeLockGlobalStats(),
      _safeLockGlobalStatsTTL,
      fromJson: (json) =>
          SafeLockGlobalStats.fromJson(json as Map<String, dynamic>),
      toJson: (stats) => stats.toJson(),
    );
  }
}
