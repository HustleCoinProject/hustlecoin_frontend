import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/safe_lock_status.dart';
import '../data/models/safe_lock_deposit_response.dart';
import '../data/models/safe_lock_claim_response.dart';
import '../data/models/safe_lock_global_stats.dart';
import '../data/repositories/data_repository.dart';
import 'foundational_providers.dart';
import 'user_provider.dart';

// Provider for Safe Lock status
final safeLockStatusProvider =
    StateNotifierProvider<SafeLockController, AsyncValue<SafeLockStatus>>((
      ref,
    ) {
      return SafeLockController(ref);
    }, dependencies: [dataRepositoryProvider, userControllerProvider]);

class SafeLockController extends StateNotifier<AsyncValue<SafeLockStatus>> {
  final Ref _ref;

  SafeLockController(this._ref) : super(const AsyncValue.loading()) {
    // Listen to user changes to auto-refresh safe lock status
    _ref.listen<AsyncValue<dynamic>>(userControllerProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            fetchStatus();
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    }, fireImmediately: true);
  }

  DataRepository get _api => _ref.read(dataRepositoryProvider);

  /// Fetch the current safe lock status
  Future<void> fetchStatus() async {
    try {
      state = const AsyncValue.loading();
      final status = await _api.getSafeLockStatus();
      state = AsyncValue.data(status);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Deposit HC to safe lock
  Future<SafeLockDepositResponse> deposit(int amount) async {
    try {
      final response = await _api.depositToSafeLock(amount);

      // Refresh user data to update balance
      await _ref.read(userControllerProvider.notifier).refresh();

      // Refresh safe lock status
      await fetchStatus();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Claim safe lock funds and rewards
  Future<SafeLockClaimResponse> claim() async {
    try {
      final response = await _api.claimSafeLock();

      // Refresh user data to update balance
      await _ref.read(userControllerProvider.notifier).refresh();

      // Refresh safe lock status
      await fetchStatus();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Manual refresh of status
  Future<void> refresh() async {
    await fetchStatus();
  }
}

// Provider to watch time remaining and trigger UI updates
final safeLockTimeRemainingProvider = StreamProvider<Duration>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) {
    final statusAsync = ref.read(safeLockStatusProvider);

    return statusAsync.when(
      data: (status) {
        if (status.lockedUntil != null) {
          final remaining = status.lockedUntil!.difference(DateTime.now());
          return remaining.isNegative ? Duration.zero : remaining;
        }
        return Duration.zero;
      },
      loading: () => Duration.zero,
      error: (_, __) => Duration.zero,
    );
  });
});

// Provider for Safe Lock global statistics
final safeLockGlobalStatsProvider = FutureProvider<SafeLockGlobalStats>((
  ref,
) async {
  final api = ref.read(dataRepositoryProvider);
  return await api.getSafeLockGlobalStats();
});
