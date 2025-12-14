import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'foundational_providers.dart';

// --- Server Time Synchronization ---

final serverTimeProvider =
    StateNotifierProvider<ServerTimeController, AsyncValue<Duration>>((ref) {
      return ServerTimeController(ref);
    }, dependencies: [dataRepositoryProvider]);

class ServerTimeController extends StateNotifier<AsyncValue<Duration>> {
  final Ref _ref;
  static const refreshInterval = Duration(minutes: 20);
  Timer? _refreshTimer;

  ServerTimeController(this._ref) : super(const AsyncValue.loading()) {
    syncWithServer();
    _refreshTimer = Timer.periodic(refreshInterval, (_) => syncWithServer());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Duration get timeOffset => state.when(
    data: (offset) => offset,
    loading: () => Duration.zero,
    error: (_, __) => Duration.zero,
  );

  DateTime get currentServerTime {
    final offset = state.when(
      data: (offset) => offset,
      loading: () => Duration.zero,
      error: (_, __) => Duration.zero,
    );
    return DateTime.now().add(offset);
  }

  Future<void> syncWithServer() async {
    try {
      final api = _ref.read(dataRepositoryProvider);
      final localTimeBefore = DateTime.now();
      final serverTime = await api.getServerTime();
      final localTimeAfter = DateTime.now();
      final latency = localTimeAfter.difference(localTimeBefore) ~/ 2;
      final adjustedServerTime = serverTime.add(latency);
      final offset = adjustedServerTime.difference(localTimeAfter);
      state = AsyncValue.data(offset);

    } catch (e, st) {
      final hasExistingValue = state.when(
        data: (_) => true,
        loading: () => false,
        error: (_, __) => false,
      );
      if (!hasExistingValue) {
        state = AsyncValue.data(Duration.zero);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  bool isTaskInCooldown(String taskId, Map<String, DateTime> cooldowns) {
    if (!cooldowns.containsKey(taskId)) return false;
    final cooldownEndTime = cooldowns[taskId]!;
    return currentServerTime.isBefore(cooldownEndTime);
  }

  Duration getRemainingCooldown(
    String taskId,
    Map<String, DateTime> cooldowns,
  ) {
    if (!cooldowns.containsKey(taskId)) return Duration.zero;
    final cooldownEndTime = cooldowns[taskId]!;
    if (currentServerTime.isAfter(cooldownEndTime)) return Duration.zero;
    return cooldownEndTime.difference(currentServerTime);
  }
}

final currentServerTimeProvider = Provider<DateTime>((ref) {
  final serverTimeController = ref.watch(serverTimeProvider.notifier);
  return serverTimeController.currentServerTime;
}, dependencies: [serverTimeProvider]);
