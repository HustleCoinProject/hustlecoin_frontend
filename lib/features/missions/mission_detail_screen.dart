import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hustlecoin/features/missions/mission_games_wrapper.dart';
import 'package:hustlecoin/providers/mission_provider.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';

class MissionDetailScreen extends ConsumerStatefulWidget {
  const MissionDetailScreen({super.key});

  @override
  ConsumerState<MissionDetailScreen> createState() =>
      _MissionDetailScreenState();
}

class _MissionDetailScreenState extends ConsumerState<MissionDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch active mission when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeMissionProvider.notifier).fetchActiveMission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final missionState = ref.watch(activeMissionProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ScreenBackground(
        imagePath:
            'assets/images/${HustleUtils.getCurrentHustleKey(ref.watch(userControllerProvider).value?.currentHustle)}.jpg',
        child: SafeArea(child: _buildBody(missionState)),
      ),
    );
  }

  Widget _buildBody(MissionState state) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.angolaYellow),
      );
    }

    if (state.allMissionsCompleted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.circleCheck,
              color: AppColors.angolaYellow,
              size: 60.s,
            ),
            SizedBox(height: 20.s),
            Text(
              'All Daily Missions Completed!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.f,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.s),
            Text(
              'Come back tomorrow for new missions.',
              style: TextStyle(color: AppColors.textGrey, fontSize: 16.f),
            ),
            SizedBox(height: 30.s),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.angolaYellow,
                foregroundColor: AppColors.angolaBlack,
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      );
    }

    if (state.currentMission == null) {
      // Fallback if something weird happens
      return Center(
        child: Text(
          'No mission available.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final mission = state.currentMission!;

    return Column(
      children: [
        // Header
        Padding(
          padding: ResponsiveUtils.pSymmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20.s),
                decoration: BoxDecoration(
                  color: AppColors.angolaYellow.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.angolaYellow, width: 2),
                ),
                child: Icon(
                  FontAwesomeIcons.rocket,
                  color: AppColors.angolaYellow,
                  size: 40.s,
                ),
              ),
              SizedBox(height: 15.s),
              Text(
                mission.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.f,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.s),
              Text(
                mission.description,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 16.f),
              ),
              SizedBox(height: 20.s),
              GlassContainer(
                padding: ResponsiveUtils.pSymmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                borderRadius: 15,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FontAwesomeIcons.coins,
                      color: AppColors.angolaYellow,
                      size: 18.s,
                    ),
                    SizedBox(width: 10.s),
                    Text(
                      'Reward: ${mission.rewardAmount} HC',
                      style: TextStyle(
                        color: AppColors.angolaYellow,
                        fontSize: 18.f,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 30.s),

        // Game List Title
        Padding(
          padding: ResponsiveUtils.pSymmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'MISSION TASKS',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14.f,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),

        SizedBox(height: 10.s),

        // Game List
        Expanded(
          child: ListView.separated(
            padding: ResponsiveUtils.pSymmetric(horizontal: 20),
            itemCount: mission.games.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.s),
            itemBuilder: (context, index) {
              final gameId = mission.games[index];
              return GlassContainer(
                padding: ResponsiveUtils.p(15),
                borderRadius: 15,
                child: Row(
                  children: [
                    Container(
                      width: 30.s,
                      height: 30.s,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.s),
                    Expanded(
                      child: Text(
                        _getGameName(gameId),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.f,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      gameId == 'balloon_pop'
                          ? FontAwesomeIcons.soap
                          : gameId == 'snake'
                          ? FontAwesomeIcons.worm
                          : gameId == 'runner'
                          ? FontAwesomeIcons.personRunning
                          : gameId == 'pong'
                          ? FontAwesomeIcons.tableTennisPaddleBall
                          : gameId == 'seagull'
                          ? FontAwesomeIcons.crow
                          : FontAwesomeIcons.gamepad,
                      color: Colors.white70,
                      size: 18.s,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Start Button
        Padding(
          padding: ResponsiveUtils.p(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(activeMissionProvider.notifier).startMission();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const MissionGamesWrapper(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.angolaYellow,
                foregroundColor: AppColors.angolaBlack,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: Text(
                'START MISSION',
                style: TextStyle(
                  fontSize: 18.f,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getGameName(String gameId) {
    switch (gameId) {
      case 'balloon_pop':
        return 'Balloon Pop';
      case 'snake':
        return 'Snake Hustle';
      case 'runner':
        return 'City Runner';
      case 'pong':
        return 'Hustle Pong';
      case 'seagull':
        return 'Sky Hustler';
      default:
        return 'Mystery Game';
    }
  }
}
