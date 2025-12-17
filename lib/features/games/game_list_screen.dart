import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/task.dart';
import 'package:hustlecoin/utils/localization.dart';

import 'package:hustlecoin/providers/foundational_providers.dart';
import 'package:hustlecoin/features/games/runner_game_screen.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';

import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/features/games/snake_game_screen.dart';
import 'package:hustlecoin/features/games/seagull_game_screen.dart';
import 'package:hustlecoin/features/games/pong_game_screen.dart';
import 'package:hustlecoin/widgets/banner_ad_widget.dart';
import 'package:hustlecoin/utils/ad_helper.dart';

class GameListScreen extends ConsumerStatefulWidget {
  const GameListScreen({super.key});

  @override
  ConsumerState<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends ConsumerState<GameListScreen> {
  Task? _miniGameTask;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTaskConfig();
  }

  Future<void> _fetchTaskConfig() async {
    try {
      final dataRepo = ref.read(dataRepositoryProvider);
      final tasks = await dataRepo.getAllTasks();
      if (!mounted) return;

      setState(() {
        _miniGameTask = tasks.firstWhere(
          (t) => t.taskId == 'mini_game_played',
          orElse: () => const Task(
            taskId: 'mini_game_played',
            description: 'Play a game',
            reward: 20,
            rankPoints: 0,
            type: 'game',
            cooldownSeconds: 60,
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to fetch tasks: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default reward text if task not loaded or 0
    final rewardText = _miniGameTask != null && _miniGameTask!.reward > 0
        ? "Win ${_miniGameTask!.reward} HC"
        : "Earn HC";

    final dataRepo = ref.read(dataRepositoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'ARCADE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: ScreenBackground(
        imagePath: 'assets/images/Hustle Legend.jpg',
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: ResponsiveUtils.p(20),
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Text(
                          ref.t(LocalizationKeys.miniGames),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16.f,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    _buildGameCard(
                      context,
                      title: ref.t(LocalizationKeys.gameRunnerTitle),
                      description: ref.t(LocalizationKeys.runnerInstruction),
                      goal:
                          '${ref.t(LocalizationKeys.goal)}: ${ref.t(LocalizationKeys.score)} 1800+',
                      reward: rewardText,
                      icon: FontAwesomeIcons.personRunning,
                      color: AppColors.angolaYellow,
                      onTap: () async {
                        await AdHelper.showInterstitialOnNavigation();
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RunnerGameScreen(
                                rewardTask: _miniGameTask,
                                targetScore: 1800,
                                dataRepository: dataRepo,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 15.s), // Spacing
                    _buildGameCard(
                      context,
                      title: ref.t(LocalizationKeys.gameSnakeTitle),
                      description: ref.t(LocalizationKeys.snakeInstruction),
                      goal:
                          '${ref.t(LocalizationKeys.goal)}: ${ref.t(LocalizationKeys.score)} 150+',
                      reward: rewardText,
                      icon: FontAwesomeIcons.staffSnake,
                      color: Colors.greenAccent,
                      onTap: () async {
                        await AdHelper.showInterstitialOnNavigation();
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SnakeGameScreen(
                                rewardTask: _miniGameTask,
                                targetScore: 150,
                                dataRepository: dataRepo,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 15.s), // Spacing
                    _buildGameCard(
                      context,
                      title: ref.t(LocalizationKeys.gameSeagullTitle),
                      description: ref.t(LocalizationKeys.seagullInstruction),
                      goal:
                          '${ref.t(LocalizationKeys.goal)}: ${ref.t(LocalizationKeys.score)} 150+',
                      reward: rewardText,
                      icon: FontAwesomeIcons.dove,
                      color: Colors.lightBlueAccent,
                      onTap: () async {
                        await AdHelper.showInterstitialOnNavigation();
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SeagullGameScreen(
                                rewardTask: _miniGameTask,
                                targetScore: 150,
                                dataRepository: dataRepo,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 15.s),
                    _buildGameCard(
                      context,
                      title: ref.t(LocalizationKeys.gamePongTitle),
                      description: ref.t(LocalizationKeys.pongInstruction),
                      goal:
                          '${ref.t(LocalizationKeys.goal)}: ${ref.t(LocalizationKeys.winMatch)}',
                      reward: rewardText,
                      icon: FontAwesomeIcons.tableTennisPaddleBall,
                      color: Colors.pinkAccent,
                      onTap: () async {
                        await AdHelper.showInterstitialOnNavigation();
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PongGameScreen(
                                rewardTask: _miniGameTask,
                                dataRepository: dataRepo,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 20.s),
                    // Banner Ad
                    const Center(
                      child: BannerAdWidget(
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    SizedBox(height: 20.s),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required String goal,
    required String reward,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return PressableScaleWidget(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: 20.r,
        padding: ResponsiveUtils.p(20),
        child: Row(
          children: [
            Container(
              width: 80.s,
              height: 80.s,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: color.withValues(alpha: 0.5),
                  width: 2.s,
                ),
              ),
              child: Center(
                child: FaIcon(icon, color: color, size: 40.s),
              ),
            ),
            SizedBox(width: 20.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.f,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 4.s),
                  Text(
                    description,
                    style: TextStyle(color: AppColors.textGrey, fontSize: 12.f),
                  ),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          goal,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.f,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          reward,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10.f,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textGrey, size: 24.s),
          ],
        ),
      ),
    );
  }
}
