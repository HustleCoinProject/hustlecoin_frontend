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
  final String currentHustle;
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
  final String currentHustle;
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

// ==========================================================================
// 2. API SERVICE REPOSITORY
// ==========================================================================
// This class handles all communication with your backend API.

class ApiRepository {
  final String _baseUrl =
      "https://hustlecoin-backend.fly.dev"; // Use 10.0.2.2 for Android emulator
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // --- Auth ---
  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['access_token'];
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<User> register(
    String email,
    String password,
    String username,
    String hustle,
    String lang,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/register'),
      headers: _headers,
      body: json.encode({
        'email': email,
        'password': password,
        'username': username,
        'current_hustle': hustle,
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
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/me'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch user data: ${response.body}');
    }
  }

  Future<List<InventoryItem>> getInventory() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/inventory'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => InventoryItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch inventory');
    }
  }

  // --- Hustles & Levels ---
  Future<Map<String, List<String>>> getAllHustles() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/hustles/all'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.map((key, value) => MapEntry(key, List<String>.from(value)));
    } else {
      throw Exception('Failed to fetch hustles');
    }
  }

  Future<LevelStatus> getLevelStatus() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/hustles/level-status'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return LevelStatus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch level status');
    }
  }

  // --- Tasks & Shop ---
  Future<List<Task>> getAllTasks() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/tasks/all'),
      headers: _headers,
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
    final response = await http.post(
      Uri.parse('$_baseUrl/api/tasks/complete'),
      headers: _headers,
      body: json.encode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to complete task: ${response.body}');
    }
  }

  Future<List<ShopItem>> getShopItems() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/shop/items'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ShopItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch shop items');
    }
  }

  Future<void> purchaseItem(String itemId, int quantity) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/shop/purchase'),
      headers: _headers,
      body: json.encode({'item_id': itemId, 'quantity': quantity}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to purchase item: ${response.body}');
    }
  }

  // --- Server Time ---
  Future<DateTime> getServerTime() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/timestamp'),
      headers: _headers,
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
    final response = await http.get(
      Uri.parse('$_baseUrl/api/tasks/quiz/fetch'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return QuizQuestion.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch quiz question: ${response.body}');
    }
  }

  // Add other API methods here (buy/sell land, etc.) following the same pattern.
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
  final token = ref.watch(authControllerProvider).value;
  repo.setToken(token);
  return repo;
}, dependencies: [authControllerProvider]);

// --- Authentication State ---

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<String?>>((ref) {
      return AuthController(ref.watch(sharedPreferencesProvider));
    });

class AuthController extends StateNotifier<AsyncValue<String?>> {
  final SharedPreferences _prefs;
  AuthController(this._prefs) : super(const AsyncValue.loading()) {
    _tryAutoLogin();
  }

  static const _tokenKey = 'authToken';

  void _tryAutoLogin() {
    final token = _prefs.getString(_tokenKey);
    state = AsyncValue.data(token);
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      // Temporarily create a repository to perform login
      final tempRepo = ApiRepository();
      final token = await tempRepo.login(username, password);
      await _prefs.setString(_tokenKey, token);
      state = AsyncValue.data(token);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
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
    // When authentication state changes, try to fetch the user
    _ref.listen<AsyncValue<String?>>(authControllerProvider, (_, next) {
      if (next.value != null) {
        _fetchUser();
      } else {
        state = const AsyncValue.data(null);
      }
    });
  }

  ApiRepository get _api => _ref.read(apiRepositoryProvider);

  Future<void> _fetchUser() async {
    // If we already have a user, don't go into a full loading state for a simple refresh.
    // This prevents UI flashes and errors in dependent providers that rely on user data.
    if (state.value == null) {
      state = const AsyncValue.loading();
    }
    try {
      final user = await _api.getMe();
      state = AsyncValue.data(user);
    } catch (e, st) {
      // If fetching user fails, it might be an expired token. Log out.
      _ref.read(authControllerProvider.notifier).logout();
      state = AsyncValue.error(e, st);
    }
  }

  // This is the "Re-fetch" pattern from the docs.
  // After any action that changes user data, we just refetch from the server
  // to ensure our local state is perfectly in sync.
  Future<void> _handleAction(Future<void> Function() action) async {
    try {
      await action();
      await _fetchUser(); // Re-fetch user data on success
    } catch (e) {
      // Optionally handle the error, e.g., show a snackbar
      print("Action failed: $e");
      // You might want to refetch even on failure to get the latest state
      await _fetchUser();
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
      print("Action failed but refetching user: $e");
    } finally {
      // Always refetch user data to get the latest balance and cooldowns.
      await _fetchUser();

      // print new user state for debugging
      print("New user state: ${state.value!.taskCooldowns}");
    }
  }

  Future<void> purchaseItem(String itemId, {int quantity = 1}) async {
    await _handleAction(() => _api.purchaseItem(itemId, quantity));
  }
}

// --- Other Data Providers ---
// These providers fetch data that is displayed in the UI but doesn't change as often.

// Static game data
final allHustlesProvider = FutureProvider<Map<String, List<String>>>((
  ref,
) async {
  return ref.watch(apiRepositoryProvider).getAllHustles();
});

final allTasksProvider = FutureProvider<List<Task>>((ref) async {
  final user = ref.watch(userControllerProvider);
  // Only fetch if the user is logged in
  if (user.value == null) return [];
  return ref.watch(apiRepositoryProvider).getAllTasks();
});

final shopItemsProvider = FutureProvider<List<ShopItem>>((ref) async {
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return [];
  return ref.watch(apiRepositoryProvider).getShopItems();
});

// User-specific data that can be refreshed
final levelStatusProvider = FutureProvider.autoDispose<LevelStatus?>((
  ref,
) async {
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return null;
  return ref.watch(apiRepositoryProvider).getLevelStatus();
});

final inventoryProvider = FutureProvider.autoDispose<List<InventoryItem>>((
  ref,
) async {
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return [];
  return ref.watch(apiRepositoryProvider).getInventory();
});

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((
  ref,
) async {
  return ref.watch(apiRepositoryProvider).getLeaderboard();
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
  return ref.watch(apiRepositoryProvider).fetchQuizQuestion();
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

      print("Server time sync completed. Offset: ${offset.inMilliseconds}ms");
    } catch (e, st) {
      print("Failed to sync with server time: $e");
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
