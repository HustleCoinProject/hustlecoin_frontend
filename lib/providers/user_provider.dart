import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user.dart';
import '../data/models/auth_tokens.dart';
import '../data/repositories/api_repository.dart';
import 'auth_provider.dart';
import 'foundational_providers.dart';
import 'user_specific_data_provider.dart';

// --- User State (The most important one) ---

final userControllerProvider =
    StateNotifierProvider<UserController, AsyncValue<User?>>(
      (ref) {
        return UserController(ref);
      },
      dependencies: [
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
              print("DEBUG: UserController saw tokens available...");
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
      debugPrint("Action failed but refetching user: $e");
    } finally {
      await _fetchUser();
    }
  }

  Future<void> purchaseItem(String itemId, {int quantity = 1}) async {
    try {
      await _api.purchaseItem(itemId, quantity);
      await _fetchUser();
      // Invalidate inventory provider to refresh it after purchase
      _ref.invalidate(inventoryProvider);
    } catch (e) {
      debugPrint("Purchase failed: $e");
      await _fetchUser();
      rethrow;
    }
  }

  Future<void> buyLand(String h3Index) async {
    try {
      await _api.buyLandTile(h3Index);
      await _fetchUser();
    } catch (e) {
      debugPrint("Land purchase failed: $e");
      await _fetchUser();
      rethrow;
    }
  }

  Future<void> sellLand(String h3Index) async {
    try {
      await _api.sellLandTile(h3Index);
      await _fetchUser();
    } catch (e) {
      debugPrint("Land sell failed: $e");
      await _fetchUser();
      rethrow;
    }
  }

  Future<void> claimLandIncome() async {
    try {
      await _api.claimLandIncome();
      await _fetchUser(); // Refresh user data to get updated balance
    } catch (e) {
      debugPrint("Land income claim failed: $e");
      await _fetchUser();
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? email,
    String? currentPassword,
    String? newPassword,
    String? language,
    String? currentHustle,
  }) async {
    try {
      await _api.updateProfile(
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
        language: language,
        currentHustle: currentHustle,
      );
      await _fetchUser();
    } catch (e) {
      debugPrint("Profile update failed: $e");
      await _fetchUser();
      rethrow;
    }
  }

  void optimisticallyUpdateBalance(int amountGained) {
    // Only update if we have a user object
    if (state.value != null) {
      final currentUser = state.value!;
      final updatedUser = User(
        id: currentUser.id,
        username: currentUser.username,
        email: currentUser.email,
        hcBalance:
            currentUser.hcBalance + amountGained, // The optimistic update
        level: currentUser.level,
        currentHustle: currentUser.currentHustle,
        levelEntryDate: currentUser.levelEntryDate,
        hcEarnedInLevel:
            currentUser.hcEarnedInLevel + amountGained, // Also update this
        language: currentUser.language,
        taskCooldowns: currentUser.taskCooldowns,
        dailyStreak: currentUser.dailyStreak,
        createdAt: currentUser.createdAt,
        dailyTapEarnings: currentUser.dailyTapEarnings,
        lastTapResetDate: currentUser.lastTapResetDate,
      );
      // Update the state with the new user object without a server call
      state = AsyncValue.data(updatedUser);
    }
  }
}
