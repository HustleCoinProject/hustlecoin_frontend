import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/features/games/balloon_pop_game_screen.dart';
import 'package:hustlecoin/features/games/pong_game_screen.dart';
import 'package:hustlecoin/features/games/runner_game_screen.dart';
import 'package:hustlecoin/features/games/seagull_game_screen.dart';
import 'package:hustlecoin/features/games/snake_game_screen.dart';
import 'package:hustlecoin/providers/mission_provider.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';

class MissionGamesWrapper extends ConsumerWidget {
  const MissionGamesWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionState = ref.watch(activeMissionProvider);

    if (missionState.isMissionCompleted) {
      return _buildMissionCompletedScreen(context, ref, missionState);
    }

    if (missionState.currentMission == null || !missionState.isMissionActive) {
      return const Scaffold(body: Center(child: Text('No active mission')));
    }

    final mission = missionState.currentMission!;
    final currentGameId = mission.games[missionState.currentGameIndex];
    final totalGames = mission.games.length;
    final currentGameIndex = missionState.currentGameIndex + 1;

    return Scaffold(
      body: Stack(
        children: [
          // The Game Widget
          _buildGameWidget(currentGameId, ref),

          // Bottom Overlay: Mission Progress
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter, // Moved to bottom
              child: Padding(
                padding: EdgeInsets.only(bottom: 20.h), // Bottom padding
                child: GlassContainer(
                  padding: ResponsiveUtils.pSymmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  borderRadius: 20,
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Text(
                    'Mission Task $currentGameIndex / $totalGames',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.f,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameWidget(String gameId, WidgetRef ref) {
    // Determine which game to show based on ID
    // Passing isMissionMode: true and the callback
    final onCompleted = () {
      ref.read(activeMissionProvider.notifier).completeCurrentGame();
    };

    // Note: We are assuming the games have been updated to accept these parameters.
    // If they haven't yet, this will cause a compile error, which we will fix in the next steps.
    switch (gameId) {
      case 'balloon_pop':
        return BalloonPopGameScreen(
          isMissionMode: true,
          onMissionCompleted: onCompleted,
        );
      case 'snake':
        return SnakeGameScreen(
          isMissionMode: true,
          onMissionCompleted: onCompleted,
        );
      case 'runner':
        return RunnerGameScreen(
          isMissionMode: true,
          targetScore: 600, // Explicitly set as per user request
          onMissionCompleted: onCompleted,
        );
      case 'pong':
        return PongGameScreen(
          isMissionMode: true,
          onMissionCompleted: onCompleted,
        );
      case 'seagull':
        return SeagullGameScreen(
          isMissionMode: true,
          onMissionCompleted: onCompleted,
        );
      default:
        return Center(
          child: Text(
            'Game $gameId not implemented yet',
            style: const TextStyle(color: Colors.white),
          ),
        );
    }
  }

  Widget _buildMissionCompletedScreen(
    BuildContext context,
    WidgetRef ref,
    MissionState state,
  ) {
    final mission = state.currentMission!;
    final user = ref.watch(userControllerProvider).value;
    return Scaffold(
      body: ScreenBackground(
        imagePath:
            'assets/images/${HustleUtils.getCurrentHustleKey(user?.currentHustle)}.jpg',
        child: Center(
          child: Padding(
            padding: ResponsiveUtils.p(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.greenAccent,
                  size: 80.s,
                ),
                SizedBox(height: 20.s),
                Text(
                  'MISSION COMPLETED!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.f,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.s),
                Text(
                  mission.title,
                  style: TextStyle(color: Colors.white70, fontSize: 18.f),
                ),
                SizedBox(height: 30.s),
                GlassContainer(
                  padding: ResponsiveUtils.p(20),
                  borderRadius: 20,
                  borderColor: AppColors.angolaYellow,
                  child: Column(
                    children: [
                      Text(
                        'REWARD EARNED',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14.f,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 10.s),
                      Text(
                        '${mission.rewardAmount} HC',
                        style: TextStyle(
                          color: AppColors.angolaYellow,
                          fontSize: 32.f,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.s),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Go back to details/home
                      // Fetch new mission AFTER navigating back to ensure smooth transition
                      // and prevent "black screen" or state conflict in the wrapper.
                      ref
                          .read(activeMissionProvider.notifier)
                          .fetchActiveMission();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'CONTINUE',
                      style: TextStyle(
                        fontSize: 18.f,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
