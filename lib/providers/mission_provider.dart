import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/data/models/mission.dart';
import 'package:hustlecoin/data/repositories/mission_repository.dart';

// State class for Mission flow
class MissionState {
  final Mission? currentMission;
  final int currentGameIndex;
  final bool isMissionActive;
  final bool isMissionCompleted;

  const MissionState({
    this.currentMission,
    this.currentGameIndex = 0,
    this.isMissionActive = false,
    this.isMissionCompleted = false,
  });

  MissionState copyWith({
    Mission? currentMission,
    int? currentGameIndex,
    bool? isMissionActive,
    bool? isMissionCompleted,
  }) {
    return MissionState(
      currentMission: currentMission ?? this.currentMission,
      currentGameIndex: currentGameIndex ?? this.currentGameIndex,
      isMissionActive: isMissionActive ?? this.isMissionActive,
      isMissionCompleted: isMissionCompleted ?? this.isMissionCompleted,
    );
  }
}

class MissionNotifier extends StateNotifier<MissionState> {
  MissionNotifier() : super(const MissionState());

  void startMission(Mission mission) {
    state = MissionState(
      currentMission: mission,
      currentGameIndex: 0,
      isMissionActive: true,
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
      // Mission Completed
      // Mission Completed
      state = state.copyWith(isMissionActive: false, isMissionCompleted: true);
      debugPrint("Mission Mission Complete");
      print("Mission Complete");
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
      return MissionNotifier();
    });
