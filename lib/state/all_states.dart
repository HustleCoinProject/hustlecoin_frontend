// lib/state/all_states.dart

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Hacky global variable to store quiz results
QuizResult? globalQuizResult;

// ==========================================================================
// 1. DART MODELS (Matching the Backend API)
// ==========================================================================
// These classes represent the data structures your app will work with.

@immutable
class User {
  final String id;
  final String username;
  final String email;
  final int hcBalance;
  final int level;
  final dynamic
  currentHustle; // Can be String (old format) or Map<String, String> (new format)
  final DateTime levelEntryDate;
  final int hcEarnedInLevel;
  final String language;
  final Map<String, DateTime> taskCooldowns;
  final int dailyStreak;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.hcBalance,
    required this.level,
    required this.currentHustle,
    required this.levelEntryDate,
    required this.hcEarnedInLevel,
    required this.language,
    required this.taskCooldowns,
    required this.dailyStreak,
    required this.createdAt,
  });

  // A factory constructor for creating a new User instance from a map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      hcBalance: json['hc_balance'],
      level: json['level'],
      currentHustle: json['current_hustle'],
      levelEntryDate: DateTime.parse(json['level_entry_date']),
      hcEarnedInLevel: json['hc_earned_in_level'],
      language: json['language'],
      taskCooldowns: (json['task_cooldowns'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, DateTime.parse(value)),
      ),
      dailyStreak: json['daily_streak'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Visual-only Kwanza balance
  int get kzBalance => (hcBalance / 8).floor();
}

@immutable
class InventoryItem {
  final String itemId;
  final int quantity;
  final DateTime purchasedAt;
  final DateTime? expiresAt;

  const InventoryItem({
    required this.itemId,
    required this.quantity,
    required this.purchasedAt,
    this.expiresAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      itemId: json['item_id'],
      quantity: json['quantity'],
      purchasedAt: DateTime.parse(json['purchased_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
    );
  }
}

@immutable
class LevelStatus {
  final int currentLevel;
  final dynamic
  currentHustle; // Can be String (old format) or Map<String, String> (new format)
  final double daysInLevelProgress;
  final int daysInLevelRequired;
  final int hcEarnedInLevelProgress;
  final int hcEarnedInLevelRequired;
  final int upgradeFee;
  final bool isEligibleForUpgrade;

  const LevelStatus({
    required this.currentLevel,
    required this.currentHustle,
    required this.daysInLevelProgress,
    required this.daysInLevelRequired,
    required this.hcEarnedInLevelProgress,
    required this.hcEarnedInLevelRequired,
    required this.upgradeFee,
    required this.isEligibleForUpgrade,
  });

  factory LevelStatus.fromJson(Map<String, dynamic> json) {
    return LevelStatus(
      currentLevel: json['current_level'],
      currentHustle: json['current_hustle'],
      daysInLevelProgress: (json['days_in_level_progress'] as num).toDouble(),
      daysInLevelRequired: json['days_in_level_required'],
      hcEarnedInLevelProgress: json['hc_earned_in_level_progress'],
      hcEarnedInLevelRequired: json['hc_earned_in_level_required'],
      upgradeFee: json['upgrade_fee'],
      isEligibleForUpgrade: json['is_eligible_for_upgrade'],
    );
  }
}

@immutable
class Task {
  final String taskId;
  final String description;
  final int reward;
  final String type;
  final int cooldownSeconds;

  const Task({
    required this.taskId,
    required this.description,
    required this.reward,
    required this.type,
    required this.cooldownSeconds,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['task_id'],
      description: json['description'],
      reward: json['reward'],
      type: json['type'],
      cooldownSeconds: json['cooldown_seconds'],
    );
  }
}

@immutable
class ShopItem {
  final String itemId;
  final String name;
  final String description;
  final int price;
  final String itemType;
  final Map<String, dynamic> metadata;

  const ShopItem({
    required this.itemId,
    required this.name,
    required this.description,
    required this.price,
    required this.itemType,
    required this.metadata,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      itemId: json['item_id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      itemType: json['item_type'],
      metadata: json['metadata'],
    );
  }
}

@immutable
class LeaderboardEntry {
  final String username;
  final int hcBalance;
  final int level;

  const LeaderboardEntry({
    required this.username,
    required this.hcBalance,
    required this.level,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      username: json['username'],
      hcBalance: json['hc_balance'],
      level: json['level'],
    );
  }
}

@immutable
class QuizQuestion {
  final String quizId;
  final String question;
  final List<String> options;

  const QuizQuestion({
    required this.quizId,
    required this.question,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      quizId: json['quizId'],
      question: json['question'],
      options: List<String>.from(json['options']),
    );
  }
}

@immutable
class QuizResult {
  final String quizId;
  final int answerIndex;

  const QuizResult({required this.quizId, required this.answerIndex});

  // toJson
  Map<String, dynamic> toJson() {
    return {'quizId': quizId, 'answerIndex': answerIndex};
  }
}

@immutable
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'refresh_token': refreshToken};
  }
}

// --- Land System Models ---

@immutable
class LandTileInfo {
  final String h3Index;
  final String ownerId;

  const LandTileInfo({required this.h3Index, required this.ownerId});

  factory LandTileInfo.fromJson(Map<String, dynamic> json) {
    return LandTileInfo(h3Index: json['h3_index'], ownerId: json['owner_id']);
  }
}

@immutable
class MyLandTile {
  final String h3Index;
  final DateTime purchasedAt;
  final int purchasePrice;

  const MyLandTile({
    required this.h3Index,
    required this.purchasedAt,
    required this.purchasePrice,
  });

  factory MyLandTile.fromJson(Map<String, dynamic> json) {
    return MyLandTile(
      h3Index: json['h3_index'],
      purchasedAt: DateTime.parse(json['purchased_at']),
      purchasePrice: json['purchase_price'],
    );
  }
}

// ==========================================================================
// 2. API SERVICE REPOSITORY
// ==========================================================================
// This class handles all communication with your backend API.

class ApiRepository {
  final String _baseUrl =
      "https://hustlecoin-backend.fly.dev"; // Use 10.0.2.2 for Android emulator
  String? _accessToken;
  String? _refreshToken;

  // Callback function to notify when tokens are refreshed
  Function(AuthTokens)? _onTokensRefreshed;

  void setTokens(String? accessToken, String? refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void setOnTokensRefreshed(Function(AuthTokens)? callback) {
    _onTokensRefreshed = callback;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // Helper method to make authenticated requests with automatic token refresh
  Future<http.Response> _makeAuthenticatedRequest(
    Future<http.Response> Function() requestFunction,
  ) async {
    try {
      final response = await requestFunction();

      // If we get a 401 and have a refresh token, try to refresh
      if (response.statusCode == 401 && _refreshToken != null) {
        print("DEBUG: Access token expired, attempting refresh...");

        try {
          // Attempt to refresh the token
          final newTokens = await _refreshAccessToken();

          // Update tokens
          setTokens(newTokens.accessToken, newTokens.refreshToken);

          // Notify the auth controller about the new tokens
          if (_onTokensRefreshed != null) {
            _onTokensRefreshed!(newTokens);
          }

          // Retry the original request with the new token
          print("DEBUG: Token refreshed successfully, retrying request...");
          return await requestFunction();
        } catch (refreshError) {
          print("DEBUG: Token refresh failed: $refreshError");
          // If refresh fails, the token is invalid, so rethrow the original 401
          throw Exception('Authentication failed: ${response.body}');
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // --- Auth ---
  Future<AuthTokens> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return AuthTokens.fromJson(responseData);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<AuthTokens> _refreshAccessToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh_token': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return AuthTokens.fromJson(responseData);
    } else {
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }

  Future<User> register(
    String email,
    String password,
    String username,
    String hustleKey, // This should be the English key
    String lang,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/register'),
      headers: _headers,
      body: json.encode({
        'email': email,
        'password': password,
        'username': username,
        'current_hustle': hustleKey, // Send the key (English name)
        'language': lang,
      }),
    );
    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // --- User ---
  Future<User> getMe() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(Uri.parse('$_baseUrl/api/users/me'), headers: _headers),
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch user data: ${response.body}');
    }
  }

  Future<void> updateProfile({
    String? email,
    String? currentPassword,
    String? newPassword,
    String? language,
    String? currentHustle,
  }) async {
    final Map<String, dynamic> body = {};

    if (email != null) body['email'] = email;
    if (currentPassword != null) body['current_password'] = currentPassword;
    if (newPassword != null) body['new_password'] = newPassword;
    if (language != null) body['language'] = language;
    if (currentHustle != null)
      body['current_hustle'] = currentHustle; // This should be the key

    final response = await _makeAuthenticatedRequest(
      () => http.put(
        Uri.parse('$_baseUrl/api/users/profile'),
        headers: _headers,
        body: json.encode(body),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  Future<List<InventoryItem>> getInventory() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(
        Uri.parse('$_baseUrl/api/users/inventory'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => InventoryItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch inventory');
    }
  }

  // --- Hustles & Levels ---
  Future<Map<String, Map<String, String>>> getAllHustles() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/hustles/all'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.map(
        (key, value) => MapEntry(
          key,
          Map<String, String>.from(value as Map<String, dynamic>),
        ),
      );
    } else {
      throw Exception('Failed to fetch hustles');
    }
  }

  Future<Map<String, String>> getAvailableHustles() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(
        Uri.parse('$_baseUrl/api/hustles/available'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Map<String, String>.from(data);
    } else {
      throw Exception('Failed to fetch available hustles');
    }
  }

  Future<LevelStatus> getLevelStatus() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(
        Uri.parse('$_baseUrl/api/hustles/level-status'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      return LevelStatus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch level status');
    }
  }

  // Level upgrade API
  Future<Map<String, dynamic>> levelUpgrade() async {
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/hustles/level-upgrade'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to upgrade level: ${response.body}');
    }
  }

  // Select new hustle API
  Future<void> selectHustle(String hustleKey) async {
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/hustles/select'),
        headers: _headers,
        body: json.encode({
          'hustle_name': hustleKey,
        }), // Send the key (English name)
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to select hustle: ${response.body}');
    }
  }

  // --- Tasks & Shop ---
  Future<List<Task>> getAllTasks() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(Uri.parse('$_baseUrl/api/tasks/all'), headers: _headers),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Task.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch tasks');
    }
  }

  Future<void> completeTask(
    String taskId, {
    Map<String, dynamic>? payload,
  }) async {
    final Map<String, dynamic> body = {'task_id': taskId};
    if (payload != null) {
      body['payload'] = payload;
    }
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/tasks/complete'),
        headers: _headers,
        body: json.encode(body),
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to complete task: ${response.body}');
    }
  }

  Future<List<ShopItem>> getShopItems() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(Uri.parse('$_baseUrl/api/shop/items'), headers: _headers),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ShopItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch shop items');
    }
  }

  Future<void> purchaseItem(String itemId, int quantity) async {
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/shop/purchase'),
        headers: _headers,
        body: json.encode({'item_id': itemId, 'quantity': quantity}),
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to purchase item: ${response.body}');
    }
  }

  // --- Server Time ---
  Future<DateTime> getServerTime() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(Uri.parse('$_baseUrl/api/timestamp'), headers: _headers),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return DateTime.parse(data['timestamp']);
    } else {
      throw Exception('Failed to fetch server time: ${response.body}');
    }
  }

  // --- Leaderboard ---
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/leaderboard'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => LeaderboardEntry.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch leaderboard');
    }
  }

  Future<QuizQuestion> fetchQuizQuestion() async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(
        Uri.parse('$_baseUrl/api/tasks/quiz/fetch'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      return QuizQuestion.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch quiz question: ${response.body}');
    }
  }

  // --- Land System ---
  Future<List<LandTileInfo>> getTilesInBbox(String bbox) async {
    final response = await _makeAuthenticatedRequest(
      () => http.get(
        Uri.parse('$_baseUrl/api/land/tiles?bbox=$bbox'),
        headers: _headers,
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => LandTileInfo.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch land tiles: ${response.body}');
    }
  }

  Future<List<MyLandTile>> getMyLands() async {
    final response = await _makeAuthenticatedRequest(
      () =>
          http.get(Uri.parse('$_baseUrl/api/land/my-lands'), headers: _headers),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => MyLandTile.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch my lands: ${response.body}');
    }
  }

  Future<void> buyLandTile(String h3Index) async {
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/land/buy/$h3Index'),
        headers: _headers,
      ),
    );
    // Backend returns 201 CREATED on successful purchase
    if (response.statusCode != 201) {
      throw Exception('Failed to buy land tile: ${response.body}');
    }
  }

  Future<void> sellLandTile(String h3Index) async {
    final response = await _makeAuthenticatedRequest(
      () => http.post(
        Uri.parse('$_baseUrl/api/land/sell/$h3Index'),
        headers: _headers,
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to sell land tile: ${response.body}');
    }
  }
}

// ==========================================================================
// 3. GLOBAL STATE PROVIDERS
// ==========================================================================
// These providers expose your app's state and business logic.

// --- Foundational Providers ---

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // This will be overridden in main.dart
  throw UnimplementedError();
});

final apiRepositoryProvider = Provider<ApiRepository>((ref) {
  final repo = ApiRepository();
  // Listen to the auth token and update the repository
  final authState = ref.watch(authControllerProvider);
  final tokens = authState.when(
    data: (tokens) => tokens,
    loading: () => null,
    error: (_, __) => null,
  );
  print(
    "DEBUG: apiRepositoryProvider - Setting tokens: ${tokens != null ? 'YES (${tokens.accessToken.substring(0, 20)}...)' : 'NO'}",
  );
  repo.setTokens(tokens?.accessToken, tokens?.refreshToken);

  // Set up token refresh callback
  repo.setOnTokensRefreshed((newTokens) {
    ref.read(authControllerProvider.notifier).updateTokens(newTokens);
  });

  return repo;
}, dependencies: [authControllerProvider]);

// --- Authentication State ---

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthTokens?>>((ref) {
      return AuthController(ref.watch(sharedPreferencesProvider));
    });

class AuthController extends StateNotifier<AsyncValue<AuthTokens?>> {
  final SharedPreferences _prefs;
  AuthController(this._prefs) : super(const AsyncValue.loading()) {
    _tryAutoLogin();
  }

  static const _tokensKey = 'authTokens';

  void _tryAutoLogin() {
    final tokensJson = _prefs.getString(_tokensKey);
    AuthTokens? tokens;
    if (tokensJson != null) {
      try {
        tokens = AuthTokens.fromJson(json.decode(tokensJson));
      } catch (e) {
        print("DEBUG: Failed to parse stored tokens: $e");
      }
    }

    print(
      "DEBUG: AuthController _tryAutoLogin - found tokens: ${tokens != null ? 'YES (${tokens.accessToken.substring(0, 20)}...)' : 'NO'}",
    );
    state = AsyncValue.data(tokens);
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      // Temporarily create a repository to perform login
      final tempRepo = ApiRepository();
      final tokens = await tempRepo.login(username, password);
      await _prefs.setString(_tokensKey, json.encode(tokens.toJson()));
      state = AsyncValue.data(tokens);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTokens(AuthTokens newTokens) async {
    try {
      await _prefs.setString(_tokensKey, json.encode(newTokens.toJson()));
      state = AsyncValue.data(newTokens);
      print("DEBUG: Tokens updated successfully");
    } catch (e) {
      print("DEBUG: Failed to update tokens: $e");
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_tokensKey);
    state = const AsyncValue.data(null);
  }
}

// --- User State (The most important one) ---

final userControllerProvider =
    StateNotifierProvider<UserController, AsyncValue<User?>>(
      (ref) {
        return UserController(ref);
      },
      dependencies: [
        // Add all dependencies to ensure they're properly tracked
        sharedPreferencesProvider,
        authControllerProvider,
        apiRepositoryProvider,
      ],
    );

class UserController extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;
  UserController(this._ref) : super(const AsyncValue.data(null)) {
    // Listen to the authentication state and fetch user when token is available
    _ref.listen<AsyncValue<AuthTokens?>>(
      authControllerProvider,
      (previous, next) {
        next.when(
          data: (tokens) {
            if (tokens != null) {
              print(
                "DEBUG: UserController saw tokens available: ${tokens.accessToken.substring(0, 20)}...",
              );
              _fetchUser();
            } else {
              print("DEBUG: UserController saw tokens cleared");
              state = const AsyncValue.data(null);
            }
          },
          loading: () {
            print("DEBUG: UserController saw auth loading state");
            // Don't do anything while auth is loading
          },
          error: (error, stack) {
            print("DEBUG: UserController saw auth error: $error");
            state = const AsyncValue.data(null);
          },
        );
      },
      fireImmediately: true,
    ); // This ensures we check the current state immediately
  }

  ApiRepository get _api => _ref.read(apiRepositoryProvider);

  Future<void> _fetchUser() async {
    // If we already have a user, don't go into a full loading state for a simple refresh.
    // This prevents UI flashes and errors in dependent providers that rely on user data.
    if (state.value == null) {
      state = const AsyncValue.loading();
    }
    try {
      print("DEBUG: UserController fetching user data...");
      final user = await _api.getMe();
      print(
        "DEBUG: UserController successfully fetched user: ${user.username}",
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      print("DEBUG: UserController failed to fetch user: $e");
      // If fetching user fails, it might be an expired token. Log out.
      _ref.read(authControllerProvider.notifier).logout();
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeTask(
    String taskId, {
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _api.completeTask(taskId, payload: payload);
    } catch (e) {
      // We still want to refetch user data even if the task "fails"
      // because a failure might still result in a cooldown being applied.
      debugPrint("Action failed but refetching user: $e");
    } finally {
      // Always refetch user data to get the latest balance and cooldowns.
      await _fetchUser();
    }
  }

  // Purchase an item with improved error handling for UI feedback
  Future<void> purchaseItem(String itemId, {int quantity = 1}) async {
    try {
      // Call the API directly so we can propagate errors to the UI
      await _api.purchaseItem(itemId, quantity);
      // If successful, refresh user data to update balance
      await _fetchUser();
    } catch (e) {
      debugPrint("Purchase failed: $e");
      // Refresh user data anyway to ensure UI is up to date
      await _fetchUser();
      // Re-throw the error so the UI can handle it
      rethrow;
    }
  }

  // Buy a land tile
  Future<void> buyLand(String h3Index) async {
    try {
      await _api.buyLandTile(h3Index);
      // On success, refresh user data for balance only
      await _fetchUser();
      // Do NOT invalidate any providers here to avoid circular dependencies
      // Let the UI handle provider invalidation after the transaction is complete
    } catch (e) {
      debugPrint("Land purchase failed: $e");
      // Still refresh user data in case the state is out of sync
      await _fetchUser();
      rethrow; // Rethrow to let the UI show an error
    }
  }

  // Sell a land tile
  Future<void> sellLand(String h3Index) async {
    try {
      await _api.sellLandTile(h3Index);
      // On success, refresh user data for balance only
      await _fetchUser();
      // Do NOT invalidate any providers here to avoid circular dependencies
      // Let the UI handle provider invalidation after the transaction is complete
    } catch (e) {
      debugPrint("Land sell failed: $e");
      // Still refresh user data in case the state is out of sync
      await _fetchUser();
      rethrow; // Rethrow to let the UI show an error
    }
  }

  // Update user profile with improved error handling for UI feedback
  Future<void> updateProfile({
    String? email,
    String? currentPassword,
    String? newPassword,
    String? language,
    String? currentHustle,
  }) async {
    try {
      // Call the API directly so we can propagate errors to the UI
      await _api.updateProfile(
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
        language: language,
        currentHustle: currentHustle,
      );
      // If successful, refresh user data to update with new values
      await _fetchUser();
    } catch (e) {
      debugPrint("Profile update failed: $e");
      // Refresh user data anyway to ensure UI is up to date
      await _fetchUser();
      // Re-throw the error so the UI can handle it
      rethrow;
    }
  }
}

// --- Other Data Providers ---
// These providers fetch data that is displayed in the UI but doesn't change as often.

// Static game data
final allHustlesProvider = FutureProvider<Map<String, Map<String, String>>>((
  ref,
) async {
  return ref.read(apiRepositoryProvider).getAllHustles();
});

final availableHustlesProvider = FutureProvider<Map<String, String>>((
  ref,
) async {
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return <String, String>{};
  return ref.read(apiRepositoryProvider).getAvailableHustles();
});

final allTasksProvider = FutureProvider<List<Task>>((ref) async {
  final user = ref.watch(userControllerProvider);
  // Only fetch if the user is logged in
  if (user.value == null) return [];
  return ref.read(apiRepositoryProvider).getAllTasks();
});

final shopItemsProvider = FutureProvider<List<ShopItem>>((ref) async {
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return [];
  return ref.read(apiRepositoryProvider).getShopItems();
});

// User-specific data that can be refreshed
final levelStatusProvider = FutureProvider.autoDispose<LevelStatus?>((
  ref,
) async {
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return null;
  return ref.read(apiRepositoryProvider).getLevelStatus();
});

final inventoryProvider = FutureProvider.autoDispose<List<InventoryItem>>((
  ref,
) async {
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return [];
  return ref.read(apiRepositoryProvider).getInventory();
});

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((
  ref,
) async {
  return ref.read(apiRepositoryProvider).getLeaderboard();
});

// Provider for fetching a single quiz question for the quiz screen
final quizQuestionProvider = FutureProvider.autoDispose<QuizQuestion>((
  ref,
) async {
  // Ensure the user is logged in before fetching
  final user = ref.watch(userControllerProvider).value;
  if (user == null) {
    throw Exception("User must be logged in to fetch a quiz question.");
  }
  return ref.read(apiRepositoryProvider).fetchQuizQuestion();
});

// --- Land System Providers ---

final landTilesProvider = FutureProvider.family
    .autoDispose<List<LandTileInfo>, String>((ref, bbox) async {
      // This provider fetches owned tiles within a specific bounding box.
      // The .family modifier allows us to pass the bbox string as a parameter.
      final user = ref.watch(userControllerProvider);
      if (user.value == null) return []; // Don't fetch if not logged in

      // Use read instead of watch for apiRepositoryProvider to avoid circular dependency
      final api = ref.read(apiRepositoryProvider);
      return api.getTilesInBbox(bbox);
    });

final myLandsProvider = FutureProvider.autoDispose<List<MyLandTile>>((
  ref,
) async {
  // This provider fetches all land tiles owned by the current user.
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return [];

  // Use read instead of watch for apiRepositoryProvider to avoid circular dependency
  final api = ref.read(apiRepositoryProvider);
  return api.getMyLands();
});

// Provider to manage server time and client-server time offset
final serverTimeProvider =
    StateNotifierProvider<ServerTimeController, AsyncValue<Duration>>((ref) {
      return ServerTimeController(ref);
    }, dependencies: [apiRepositoryProvider]);

class ServerTimeController extends StateNotifier<AsyncValue<Duration>> {
  final Ref _ref;

  // Set a refresh interval (e.g., every 10 minutes)
  static const refreshInterval = Duration(minutes: 10);

  // Timer for periodic refreshes
  Timer? _refreshTimer;

  ServerTimeController(this._ref) : super(const AsyncValue.loading()) {
    // Initial sync when the app starts
    syncWithServer();

    // Set up periodic refresh
    _refreshTimer = Timer.periodic(refreshInterval, (_) => syncWithServer());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Get the current offset
  Duration get timeOffset => state.value ?? Duration.zero;

  // Get the current server time
  DateTime get currentServerTime {
    final offset = state.value ?? Duration.zero;
    return DateTime.now().add(offset);
  }

  // Synchronize with the server
  Future<void> syncWithServer() async {
    try {
      final api = _ref.read(apiRepositoryProvider);

      // Record local time before the request
      final localTimeBefore = DateTime.now();

      // Get server time
      final serverTime = await api.getServerTime();

      // Record local time after the request
      final localTimeAfter = DateTime.now();

      // Calculate network latency (approximately)
      final latency = localTimeAfter.difference(localTimeBefore) ~/ 2;

      // Adjust server time by adding the latency
      final adjustedServerTime = serverTime.add(latency);

      // Calculate the offset between local time and server time
      final offset = adjustedServerTime.difference(localTimeAfter);

      // Update the state with the calculated offset
      state = AsyncValue.data(offset);

      debugPrint(
        "Server time sync completed. Offset: ${offset.inMilliseconds}ms",
      );
    } catch (e, st) {
      debugPrint("Failed to sync with server time: $e");
      // If we already have an offset, keep it; otherwise, set to zero
      if (state.value == null) {
        state = AsyncValue.data(Duration.zero);
      }
      // Still mark as error for debugging purposes
      state = AsyncValue.error(e, st);
    }
  }

  // Calculate if a task is in cooldown using server time
  bool isTaskInCooldown(String taskId, Map<String, DateTime> cooldowns) {
    if (!cooldowns.containsKey(taskId)) {
      return false;
    }

    // Get the cooldown time from the user data
    final cooldownEndTime = cooldowns[taskId]!;

    // Use the current server time for comparison
    final serverNow = currentServerTime;

    // Check if the cooldown has expired
    return serverNow.isBefore(cooldownEndTime);
  }

  // Calculate remaining cooldown duration using server time
  Duration getRemainingCooldown(
    String taskId,
    Map<String, DateTime> cooldowns,
  ) {
    if (!cooldowns.containsKey(taskId)) {
      return Duration.zero;
    }

    // Get the cooldown time from the user data
    final cooldownEndTime = cooldowns[taskId]!;

    // Use the current server time for comparison
    final serverNow = currentServerTime;

    // If cooldown has expired, return zero duration
    if (serverNow.isAfter(cooldownEndTime)) {
      return Duration.zero;
    }

    // Calculate and return remaining time
    return cooldownEndTime.difference(serverNow);
  }
}

// Provider to help easily access server time
final currentServerTimeProvider = Provider<DateTime>((ref) {
  // Access the server time controller
  final serverTimeController = ref.watch(serverTimeProvider.notifier);

  // Return the current server time
  return serverTimeController.currentServerTime;
}, dependencies: [serverTimeProvider]);
