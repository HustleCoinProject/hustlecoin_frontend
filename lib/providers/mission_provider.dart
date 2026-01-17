import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/data/models/mission.dart';

import 'package:hustlecoin/data/repositories/mission_repository.dart';
import 'package:hustlecoin/data/repositories/api_repository.dart';
import 'package:hustlecoin/providers/foundational_providers.dart';

// State class for Mission flow
class MissionState {
  final Mission? currentMission;
  final int currentGameIndex;
  final bool isMissionActive;
  final bool isMissionCompleted;
  final bool isLoading;
  final String? errorMessage;

  // Availability status
  final bool isAvailable;
  final DateTime? cooldownExpiresAt;
  final bool allMissionsCompleted;

  const MissionState({
    this.currentMission,
    this.currentGameIndex = 0,
    this.isMissionActive = false,
    this.isMissionCompleted = false,
    this.isLoading = false,
    this.errorMessage,
    this.isAvailable = false,
    this.cooldownExpiresAt,
    this.allMissionsCompleted = false,
  });

  MissionState copyWith({
    Mission? currentMission,
    int? currentGameIndex,
    bool? isMissionActive,
    bool? isMissionCompleted,
    bool? isLoading,
    String? errorMessage,
    bool? isAvailable,
    DateTime? cooldownExpiresAt,
    bool? allMissionsCompleted,
  }) {
    return MissionState(
      currentMission: currentMission ?? this.currentMission,
      currentGameIndex: currentGameIndex ?? this.currentGameIndex,
      isMissionActive: isMissionActive ?? this.isMissionActive,
      isMissionCompleted: isMissionCompleted ?? this.isMissionCompleted,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAvailable: isAvailable ?? this.isAvailable,
      cooldownExpiresAt: cooldownExpiresAt ?? this.cooldownExpiresAt,
      allMissionsCompleted: allMissionsCompleted ?? this.allMissionsCompleted,
    );
  }
}

class MissionNotifier extends StateNotifier<MissionState> {
  final ApiRepository _apiRepository;
  final MissionRepository _missionRepository;

  MissionNotifier(this._apiRepository, this._missionRepository)
    : super(const MissionState());

  Future<void> fetchActiveMission() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final statuses = await _apiRepository.getTaskStatuses();
      final missions = _missionRepository.getMissions();

      // Find the first mission that is either available OR the first one if all are unavailable but not "completed" in a permanent sense
      // User requirement: "sequential... priority smaller missions first... any mission not in cooldown shown"

      Mission? selectedMission;

      // Check missions in order 1..4
      for (final mission in missions) {
        final status = statuses.firstWhere(
          (s) => s.taskId == mission.id,
          orElse: () =>
              throw Exception('Mission status not found for ${mission.id}'),
        );

        if (status.isAvailable) {
          selectedMission = mission;
          break; // Found the next available mission
        }

        // If not available, it's on cooldown (completed for the day)
      }

      if (selectedMission == null) {
        // All on cooldown?
        // Check if we should show the first one's cooldown or a "All Done" state.
        // Let's assume generic "All Done" state, but we might want to show when M1 resets.
        // For now, if all are cooldown, we set allMissionsCompleted = true.
        // Exception: If M1 is available, we show it. If M1 is cooldown, we check M2.
        // If ALL are cooldown, then truly all done.

        // Find the mission with the earliest cooldown expiry to maybe show a timer?
        // For now, simply:
        state = state.copyWith(
          isLoading: false,
          currentMission: null,
          allMissionsCompleted: true,
          isAvailable: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          currentMission: selectedMission,
          isAvailable: true,
          allMissionsCompleted: false,
          cooldownExpiresAt: null, // It is available
          currentGameIndex: 0,
          isMissionActive: false,
          isMissionCompleted: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void startMission() {
    if (state.currentMission == null || !state.isAvailable) return;
    state = state.copyWith(
      isMissionActive: true,
      currentGameIndex: 0,
      isMissionCompleted: false,
    );
  }

  void completeCurrentGame() {
    if (!state.isMissionActive || state.currentMission == null) return;

    final nextIndex = state.currentGameIndex + 1;
    if (nextIndex < state.currentMission!.games.length) {
      // Proceed to next game
      state = state.copyWith(currentGameIndex: nextIndex);
    } else {
      // Mission Completed locally
      _completeMissionOnBackend();
    }
  }

  Future<void> _completeMissionOnBackend() async {
    final missionId = state.currentMission?.id;
    if (missionId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      await _apiRepository.completeTask(missionId);

      // Success
      state = state.copyWith(
        isLoading: false,
        isMissionActive: false,
        isMissionCompleted: true,
      );

      // Refresh to get next mission
      // await fetchActiveMission(); // Removed: Let UI trigger this to keep "Completed" state visible
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to claim reward: $e',
        // In case of error, we stay in active state or?
        // User likely wants to retry. But game is done.
        // We'll mark completed locally but show error?
        // Let's just return to completed state so they can try "Claim" again if we had a button,
        // but here it's auto.
        // For safety, if error, we might need a manual "Retry" button or just Fetch again.
        isMissionActive: false,
        isMissionCompleted: true, // UI will show "Next" or "Error"
      );
    }
  }

  void resetMission() {
    state = const MissionState();
  }
}

final missionRepositoryProvider = Provider((ref) => MissionRepository());

final missionsProvider = Provider<List<Mission>>((ref) {
  final repository = ref.watch(missionRepositoryProvider);
  return repository.getMissions();
});

final activeMissionProvider =
    StateNotifierProvider<MissionNotifier, MissionState>((ref) {
      final apiRepo = ref.watch(apiRepositoryProvider);
      final missionRepo = ref.watch(missionRepositoryProvider);
      return MissionNotifier(apiRepo, missionRepo);
    });
