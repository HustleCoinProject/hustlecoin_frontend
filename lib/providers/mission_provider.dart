import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hustlecoin/data/models/mission.dart';

import 'package:hustlecoin/data/repositories/mission_repository.dart';
import 'package:hustlecoin/data/repositories/api_repository.dart';
import 'package:hustlecoin/providers/foundational_providers.dart';
import 'package:hustlecoin/providers/time_provider.dart';

// State class for Mission flow
class MissionState {
  final Mission? currentMission;
  final DateTime? missionStartTime;
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
    this.missionStartTime,
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
    DateTime? missionStartTime,
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
      missionStartTime: missionStartTime ?? this.missionStartTime,
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
  final Ref _ref;

  MissionNotifier(this._apiRepository, this._missionRepository, this._ref)
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
        state = state.copyWith(
          isLoading: false,
          currentMission: null,
          allMissionsCompleted: true,
          isAvailable: false,
        );
      } else {
        // Check if there is a saved start time for this mission
        final prefs = await SharedPreferences.getInstance();
        final savedStartTimeStr = prefs.getString(
          'missionStartTime_${selectedMission.id}',
        );
        DateTime? savedStartTime;
        bool isActive = false;

        if (savedStartTimeStr != null) {
          savedStartTime = DateTime.parse(savedStartTimeStr);
          isActive = true;
        }

        state = state.copyWith(
          isLoading: false,
          currentMission: selectedMission,
          isAvailable: true,
          allMissionsCompleted: false,
          cooldownExpiresAt: null, // It is available
          missionStartTime: savedStartTime,
          isMissionActive: isActive,
          isMissionCompleted: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> startMission() async {
    if (state.currentMission == null || !state.isAvailable) return;

    final currentServerTime = _ref
        .read(serverTimeProvider.notifier)
        .currentServerTime;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'missionStartTime_${state.currentMission!.id}',
      currentServerTime.toIso8601String(),
    );

    state = state.copyWith(
      isMissionActive: true,
      missionStartTime: currentServerTime,
      isMissionCompleted: false,
    );
  }

  Future<void> speedupMission(int secondsToReduce) async {
    if (!state.isMissionActive ||
        state.currentMission == null ||
        state.missionStartTime == null)
      return;

    final newStartTime = state.missionStartTime!.subtract(
      Duration(seconds: secondsToReduce),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'missionStartTime_${state.currentMission!.id}',
      newStartTime.toIso8601String(),
    );

    state = state.copyWith(missionStartTime: newStartTime);
  }

  Future<void> completeMissionOnBackend() async {
    final missionId = state.currentMission?.id;
    if (missionId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      await _apiRepository.completeTask(missionId);

      // Clear the saved start time
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('missionStartTime_$missionId');

      // Success
      state = state.copyWith(
        isLoading: false,
        isMissionActive: false,
        isMissionCompleted: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to claim reward: $e',
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
      return MissionNotifier(apiRepo, missionRepo, ref);
    });
