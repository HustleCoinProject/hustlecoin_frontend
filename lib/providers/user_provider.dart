import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user.dart';
import '../data/models/auth_tokens.dart';
import '../data/repositories/data_repository.dart';
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
        dataRepositoryProvider,
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
              _fetchUser();
            } else {
              state = const AsyncValue.data(null);
            }
          },
          loading: () {
            // Don't do anything while auth is loading
          },
          error: (error, stack) {
            state = const AsyncValue.data(null);
          },
        );
      },
      fireImmediately: true,
    ); // This ensures we check the current state immediately
  }

  DataRepository get _api => _ref.read(dataRepositoryProvider);

  Future<void> _fetchUser() async {
    final hasUserData = state.when(
      data: (user) => user != null,
      loading: () => false,
      error: (_, __) => false,
    );
    if (!hasUserData) {
      state = const AsyncValue.loading();
    }
    try {
      final user = await _api.getMe();
      state = AsyncValue.data(user);
    } catch (e, st) {
      _ref.read(authControllerProvider.notifier).logout();
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeTask(
    String taskId, {
    Map<String, dynamic>? payload,
  }) async {
    try {
      final response = await _api.completeTask(taskId, payload: payload);

      // Update user state with the response data instead of refetching
      state.whenData((currentUser) {
        if (currentUser != null) {
          // Create updated task cooldowns map
          final updatedCooldowns = Map<String, DateTime>.from(
            currentUser.taskCooldowns,
          );

          // Update the cooldown for this specific task if provided in response
          if (response.cooldownExpiresAt != null) {
            updatedCooldowns[taskId] = response.cooldownExpiresAt!;
          }

          state = AsyncValue.data(
            currentUser.copyWith(
              hpScore: response.newBalance,
              rankPoints: response.newRankPoints,
              taskCooldowns: updatedCooldowns,
            ),
          );
        }
      });
    } catch (e) {
      // Only refetch on error as fallback
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
      await _fetchUser();
      rethrow;
    }
  }

  Future<void> buyLand(String h3Index) async {
    try {
      await _api.buyLandTile(h3Index);
      await _fetchUser();
    } catch (e) {
      await _fetchUser();
      rethrow;
    }
  }

  Future<void> sellLand(String h3Index) async {
    try {
      await _api.sellLandTile(h3Index);
      await _fetchUser();
    } catch (e) {
      await _fetchUser();
      rethrow;
    }
  }

  Future<void> claimLandIncome() async {
    try {
      await _api.claimLandIncome();
      await _fetchUser(); // Refresh user data to get updated balance
    } catch (e) {
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
      await _fetchUser();
      rethrow;
    }
  }

  void optimisticallyUpdateBalance(
    int amountGained, {
    int rankPointsGained = 0,
  }) {
    // Only update if we have a user object
    final currentUser = state.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );
    if (currentUser != null) {
      final updatedUser = User(
        id: currentUser.id,
        username: currentUser.username,
        email: currentUser.email,
        hpScore:
            currentUser.hpScore + amountGained, // The optimistic update
        rankPoints:
            currentUser.rankPoints + rankPointsGained, // Add rank points update
        level: currentUser.level,
        currentHustle: currentUser.currentHustle,
        levelEntryDate: currentUser.levelEntryDate,
        hpEarnedInLevel:
            currentUser.hpEarnedInLevel + amountGained, // Also update this
        language: currentUser.language,
        taskCooldowns: currentUser.taskCooldowns,
        dailyStreak: currentUser.dailyStreak,
        createdAt: currentUser.createdAt,
        dailyTapEarnings: currentUser.dailyTapEarnings,
        lastTapResetDate: currentUser.lastTapResetDate,
        phoneNumber: currentUser.phoneNumber,
        fullName: currentUser.fullName,
        nationalId: currentUser.nationalId,
        cryptoWalletAddress: currentUser.cryptoWalletAddress,
        cryptoNetwork: currentUser.cryptoNetwork,
      );
      // Update the state with the new user object without a server call
      state = AsyncValue.data(updatedUser);
    }
  }

  /// Manually refresh user data from the server
  Future<void> refresh() async {
    await _fetchUser();
  }
}
