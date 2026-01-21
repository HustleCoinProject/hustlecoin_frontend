import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/leaderboard_entry.dart';
import '../data/models/history_week.dart';
import 'foundational_providers.dart';

class LeaderboardState {
  final List<LeaderboardEntry> entries;
  final List<HistoryWeek> historyList;
  final String? selectedHistoryId;

  const LeaderboardState({
    this.entries = const [],
    this.historyList = const [],
    this.selectedHistoryId,
  });
}

final leaderboardProvider =
    AsyncNotifierProvider.autoDispose<LeaderboardNotifier, LeaderboardState>(
      LeaderboardNotifier.new,
    );

class LeaderboardNotifier extends AutoDisposeAsyncNotifier<LeaderboardState> {
  @override
  Future<LeaderboardState> build() async {
    final repo = ref.read(dataRepositoryProvider);

    // Initial fetch of history list
    List<HistoryWeek> history = [];
    try {
      history = await repo.getLeaderboardHistoryList();
    } catch (e) {
      print('Error fetching history list: $e');
    }

    // Initial fetch of current leaderboard
    final entries = await repo.getLeaderboard();

    return LeaderboardState(
      entries: entries,
      historyList: history,
      selectedHistoryId: null,
    );
  }

  Future<void> selectWeek(String? historyId) async {
    final previousState = state.value;
    final history = previousState?.historyList ?? [];

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(dataRepositoryProvider);
      List<LeaderboardEntry> entries;

      if (historyId == null) {
        entries = await repo.getLeaderboard();
      } else {
        entries = await repo.getLeaderboardHistoryDetail(historyId);
      }

      return LeaderboardState(
        entries: entries,
        historyList: history,
        selectedHistoryId: historyId,
      );
    });
  }
}
