import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/tapping_status.dart';
import '../data/models/tap_response.dart';
import 'foundational_providers.dart';
import 'time_provider.dart';

// Tapping status notifier that manages the current tapping status
class TappingStatusNotifier extends AsyncNotifier<TappingStatus> {
  Timer? _resetCheckTimer;

  @override
  Future<TappingStatus> build() async {
    // Clean up timer on dispose
    ref.onDispose(() {
      _resetCheckTimer?.cancel();
    });
    
    // Fetch initial tapping status when the notifier is built
    final status = await _fetchTappingStatus();
    _scheduleNextResetCheck(status);
    return status;
  }

  Future<TappingStatus> _fetchTappingStatus() async {
    final dataRepository = ref.read(dataRepositoryProvider);
    try {
      return await dataRepository.getTappingStatus();
    } catch (e) {
      print('Failed to fetch tapping status: $e');
      // Return a default status if fetching fails
      return const TappingStatus(
        dailyEarnings: 0,
        dailyLimit: 200,
        remainingTaps: 200,
        canTap: true,
      );
    }
  }

  // Refresh the tapping status from the server
  Future<void> refreshStatus() async {
    state = const AsyncValue.loading();
    try {
      final newStatus = await _fetchTappingStatus();
      state = AsyncValue.data(newStatus);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update tapping status based on tap response from the server
  void updateFromTapResponse(TapResponse tapResponse) {
    final currentStatus = state.when(
      data: (status) => status,
      loading: () => null,
      error: (_, __) => null,
    );
    if (currentStatus == null) return;

    final newStatus = TappingStatus(
      dailyEarnings: tapResponse.dailyEarnings,
      dailyLimit: tapResponse.dailyLimit,
      remainingTaps: tapResponse.remainingTaps,
      canTap: tapResponse.remainingTaps > 0,
      nextResetAt: tapResponse.nextResetAt,
    );

    state = AsyncValue.data(newStatus);
    _scheduleNextResetCheck(newStatus);
  }

  // Schedule a timer to check for reset at the appropriate time
  void _scheduleNextResetCheck(TappingStatus status) {
    _resetCheckTimer?.cancel();
    
    if (status.nextResetAt != null) {
      // Use server time to calculate accurate time until reset
      final serverTime = ref.read(serverTimeProvider.notifier).currentServerTime;
      final timeUntilReset = status.nextResetAt!.difference(serverTime);
      
      if (timeUntilReset.inMilliseconds > 0) {
        // Schedule a refresh slightly after the reset time
        _resetCheckTimer = Timer(timeUntilReset + const Duration(seconds: 5), () {
          refreshStatus();
        });
      }
    }
  }



  // Check if the daily limit has been reached based on next reset time
  bool get hasReachedDailyLimit {
    final status = state.when(
      data: (status) => status,
      loading: () => null,
      error: (_, __) => null,
    );
    if (status == null) return false;
    
    // If we have a next reset time, check if it's in the future using server time
    if (status.nextResetAt != null) {
      // Use server time to avoid timezone issues
      final serverTime = ref.read(serverTimeProvider.notifier).currentServerTime;
      // If next reset is in the future, we might be in a cooldown period
      if (serverTime.isBefore(status.nextResetAt!)) {
        // Direct check without circular reference
        return status.remainingTaps <= 0 || !status.canTap;
      } else {
        // Reset time has passed, we should refresh the status
        Future.microtask(() => refreshStatus());
        return false;
      }
    }
    
    // Direct check without circular reference
    return status.remainingTaps <= 0 || !status.canTap;
  }
}

// Provider for the tapping status notifier
final tappingStatusProvider = AsyncNotifierProvider<TappingStatusNotifier, TappingStatus>(() {
  final notifier = TappingStatusNotifier();
  // Add a dispose callback to clean up the timer
  return notifier;
});