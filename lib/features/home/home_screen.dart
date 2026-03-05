import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/quiz_result.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:hustlecoin/data/models/user.dart';
import 'package:hustlecoin/features/events/events_screen.dart';
import 'package:hustlecoin/features/land/land_map_screen.dart';
import 'package:hustlecoin/features/leaderboard/leaderboard_screen.dart';
import 'package:hustlecoin/features/payout/payout_screen.dart';
import 'package:hustlecoin/features/profile/edit_profile.dart';
import 'package:hustlecoin/features/quiz/quiz_screen.dart';
import 'package:hustlecoin/features/safe_lock/safe_lock_screen.dart';
import 'package:hustlecoin/features/settings/settings_screen.dart';

import 'package:hustlecoin/features/home/widgets/resource_bars_widget.dart';
import 'package:hustlecoin/features/missions/widgets/mission_card.dart';
import 'package:hustlecoin/providers/mission_provider.dart';

import 'package:hustlecoin/providers/time_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/providers/tapping_provider.dart';
import 'package:hustlecoin/providers/tapping_status_provider.dart';
import 'package:hustlecoin/services/admob_service.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/services/tutorial_service.dart';
import 'package:hustlecoin/widgets/access_controlled_widget.dart';
import 'package:hustlecoin/utils/ad_helper.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'dart:async'; // For Timer
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:hustlecoin/widgets/screen_background.dart';

import './widgets/top_bar.dart';
import './widgets/bottom_nav_bar.dart';
import './widgets/cooldown_task_button.dart';
import './widgets/stats_container.dart';
import './widgets/upgrades_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// Server time provider that updates every second
final serverTimeWatcherProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) {
    final serverTimeController = ref.read(serverTimeProvider.notifier);
    return serverTimeController.currentServerTime;
  });
});

// Task state management - Use Provider.family for automatic updates
final taskStateProvider = Provider.family<TaskState, String>((ref, taskId) {
  // Watch server time to trigger updates every second
  ref.watch(serverTimeWatcherProvider);

  // Check if the task is on cooldown
  final userState = ref.watch(userControllerProvider);
  final user = userState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
  if (user == null) return TaskState.disabled;

  // Get the server time controller
  final serverTimeController = ref.watch(serverTimeProvider.notifier);

  if (user.taskCooldowns.containsKey(taskId)) {
    final cooldownExpiry = user.taskCooldowns[taskId]!;
    // Use server time to check if the cooldown has expired
    final serverNow = serverTimeController.currentServerTime;
    if (serverNow.isBefore(cooldownExpiry)) {
      return TaskState.cooldown;
    }
  }

  return TaskState.available;
});

// Task state for loading - separate StateProvider for each task
final taskLoadingStateProvider = StateProvider.family<bool, String>(
  (ref, taskId) => false,
);

// Task controller to handle task completion
class TaskController {
  final WidgetRef ref;
  final String taskId;

  TaskController(this.ref, this.taskId);

  bool get isOnCooldown {
    final taskState = ref.read(taskStateProvider(taskId));
    return taskState == TaskState.cooldown;
  }

  bool get isAvailable {
    final taskState = ref.read(taskStateProvider(taskId));
    return taskState == TaskState.available;
  }

  bool get isLoading {
    return ref.read(taskLoadingStateProvider(taskId));
  }

  Duration? get remainingCooldown {
    final userState = ref.read(userControllerProvider);
    final user = userState.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );
    if (user == null || !user.taskCooldowns.containsKey(taskId)) return null;

    final cooldownExpiry = user.taskCooldowns[taskId]!;

    // Get the server time controller
    final serverTimeController = ref.read(serverTimeProvider.notifier);
    // Use server time to calculate remaining cooldown
    final serverNow = serverTimeController.currentServerTime;

    if (serverNow.isAfter(cooldownExpiry)) return null;

    return cooldownExpiry.difference(serverNow);
  }

  Future<void> completeTask({Map<String, dynamic>? payload = const {}}) async {
    if (!isAvailable) return;

    // Set task to loading state
    ref.read(taskLoadingStateProvider(taskId).notifier).state = true;

    try {
      await ref
          .read(userControllerProvider.notifier)
          .completeTask(taskId, payload: payload);

      // Play earn coins sound on successful task completion
      // (already called before completeTask() call) SoundService().playEarnCoins();

      // Show interstitial ad after task completion
      AdHelper.showInterstitialAfterTask();
    } catch (e) {
      // Show error snackbar
      if (ref.read(taskLoadingStateProvider(taskId).notifier).mounted) {
        // Assuming we can get context somehow... wait, we don't have BuildContext in TaskController.
        // Actually, let's just let it be, or we can use a global navigator key or pass BuildContext.
        // This TaskController is instantiated from inside a Consumer `builder: (context, ref, child)`.
        // We can just add a `BuildContext context` parameter to `completeTask`.
      }
    } finally {
      // Reset loading state
      if (ref.read(taskLoadingStateProvider(taskId).notifier).mounted) {
        ref.read(taskLoadingStateProvider(taskId).notifier).state = false;
      }
    }
  }
}

enum TaskState {
  available, // Task can be performed
  loading, // Task is being processed
  cooldown, // Task is on cooldown
  disabled, // Task is disabled (e.g. user not logged in)
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _activeNavIndex = 0;
  TutorialCoachMark? _tutorialCoachMark;

  // Global keys for tutorial targets
  final GlobalKey _hcBalanceKey = GlobalKey();
  final GlobalKey _leftTasksKey = GlobalKey();
  final GlobalKey _rightFeaturesKey = GlobalKey();
  final GlobalKey _profileNavKey = GlobalKey();
  final GlobalKey _getPaidKey = GlobalKey();
  final GlobalKey _playGameKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Show tutorial after first frame if user hasn't seen it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
      ref.read(activeMissionProvider.notifier).fetchActiveMission();
    });
  }

  Future<void> _checkAndShowTutorial() async {
    // Reset tutorial on every app start (remove this line to show only once)
    // await TutorialService.resetTutorial();

    final hasCompleted = await TutorialService.hasCompletedTutorial();
    if (!hasCompleted && mounted) {
      _showTutorial();
    }
  }

  void _showTutorial() {
    final targets = _createTutorialTargets();
    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF1a1a2e),
      paddingFocus: 10,
      opacityShadow: 0.85,
      onFinish: () {
        TutorialService.markTutorialCompleted();
      },
      onSkip: () {
        TutorialService.markTutorialCompleted();
        return true;
      },
    );
    _tutorialCoachMark!.show(context: context);
  }

  List<TargetFocus> _createTutorialTargets() {
    return [
      TargetFocus(
        identify: 'hpScore',
        keyTarget: _hcBalanceKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.t(LocalizationKeys.tutorialHcBalanceTitle),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    ref.t(LocalizationKeys.tutorialHcBalanceDesc),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'leftTasks',
        keyTarget: _leftTasksKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.right,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.t(LocalizationKeys.tutorialEarnTasksTitle),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    ref.t(LocalizationKeys.tutorialEarnTasksDesc),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'rightFeatures',
        keyTarget: _rightFeaturesKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.left,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.t(LocalizationKeys.tutorialPremiumFeaturesTitle),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    ref.t(LocalizationKeys.tutorialPremiumFeaturesDesc),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'getPaid',
        keyTarget: _getPaidKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.t(LocalizationKeys.tutorialGetPaidTitle),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    ref.t(LocalizationKeys.tutorialGetPaidDesc),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'profile',
        keyTarget: _profileNavKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.t(LocalizationKeys.tutorialProfileTitle),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    ref.t(LocalizationKeys.tutorialProfileDesc),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'playGame',
        keyTarget: _playGameKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.t(LocalizationKeys.tutorialPlayGamesTitle),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    ref.t(LocalizationKeys.tutorialPlayGamesDesc),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: 'welcome',
        keyTarget: _hcBalanceKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(
              top: MediaQuery.of(context).size.height * 0.4,
            ),
            builder: (context, controller) {
              return Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.celebration,
                      color: AppColors.angolaYellow,
                      size: 60,
                    ),
                    SizedBox(height: 20),
                    Text(
                      ref.t(LocalizationKeys.tutorialWelcomeTitle),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      ref.t(LocalizationKeys.tutorialWelcomeDesc),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 25),
                    Text(
                      ref.t(LocalizationKeys.tutorialLetsStart),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.angolaYellow,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];
  }

  // Method to toggle language between EN and PT
  Future<void> _toggleLanguage() async {
    final userController = ref.read(userControllerProvider.notifier);
    final currentUser = ref.read(userControllerProvider).value;
    if (currentUser == null) return;

    final newLanguage = currentUser.language == 'en' ? 'pt' : 'en';
    try {
      await userController.updateProfile(language: newLanguage);
    } catch (e) {}
  }

  void _onNavItemTapped(int index) {
    // Navigate to different screens based on the index
    switch (index) {
      case 0:
        // Home - already here, just update the state
        setState(() {
          _activeNavIndex = 0;
        });
        break;
      case 1:
        // Leaderboard
        AdHelper.showInterstitialOnNavigation();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const LeaderboardScreen()))
            .then((_) {
              // Reset to home when returning
              setState(() {
                _activeNavIndex = 0;
              });
            });
        break;
      case 2:
        // Profile
        AdHelper.showInterstitialOnNavigation();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const EditProfileScreen()))
            .then((_) {
              // Reset to home when returning
              setState(() {
                _activeNavIndex = 0;
              });
            });
        break;
      case 3:
        // Settings
        AdHelper.showInterstitialOnNavigation();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SettingsScreen()))
            .then((_) {
              // Reset to home when returning
              setState(() {
                _activeNavIndex = 0;
              });
            });
        break;
    }
  }

  void _onGetPaidTapped() {
    // Navigate to Payout screen
    AdHelper.showInterstitialOnNavigation();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PayoutScreen())).then((_) {
      // Reset to home when returning
      setState(() {
        _activeNavIndex = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);

    return userState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            backgroundColor: AppColors.angolaBlack,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildHomeScreen(context, user);
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.angolaBlack,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.angolaBlack,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(userControllerProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeScreen(BuildContext context, User user) {
    if (true) {
      return Scaffold(
        body: ScreenBackground(
          imagePath:
              'assets/images/${HustleUtils.getCurrentHustleKey(user.currentHustle)}.jpg',
          child: SafeArea(
            child: Column(
              children: [
                TopBar(
                  onToggleLanguage: _toggleLanguage,
                  hpScoreKey: _hcBalanceKey,
                ),
                const ResourceBarsWidget(),
                SizedBox(height: 24.h),
                Expanded(child: _buildGameArea(user, ref)),

                // Show mission card just above upgrades/inventory
                const UpgradesSection(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          activeIndex: _activeNavIndex,
          onNavItemTapped: _onNavItemTapped,
          onGetPaidTapped: _onGetPaidTapped,
          getPaidKey: _getPaidKey,
          profileNavKey: _profileNavKey,
        ),
      );
    }
  }

  Widget _buildDailyRewardButton() {
    return Consumer(
      builder: (context, ref, child) {
        final taskState = ref.watch(taskStateProvider('daily_check_in'));
        final taskController = TaskController(ref, 'daily_check_in');

        return _buildDailyRewardTaskButton(taskState, taskController);
      },
    );
  }

  Widget _buildDailyRewardTaskButton(
    TaskState taskState,
    TaskController taskController,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        // Determine button text based on state
        String buttonText = ref.t(LocalizationKeys.dailyReward);
        if (taskState == TaskState.loading) {
          buttonText = '${ref.t(LocalizationKeys.loading)}...';
        } else if (taskState == TaskState.cooldown) {
          // Get the remaining cooldown based on server time
          final remainingTime = taskController.remainingCooldown;
          if (remainingTime != null) {
            // If cooldown time is large (like a day), show hours remaining
            if (remainingTime.inHours > 0) {
              final hours = remainingTime.inHours;
              buttonText = '$hours ${ref.t(LocalizationKeys.hrsLeft)}';
            } else {
              // For shorter times, show minutes:seconds
              final minutes = remainingTime.inMinutes.remainder(60);
              final seconds = remainingTime.inSeconds.remainder(60);
              buttonText = '$minutes:${seconds.toString().padLeft(2, '0')}';
            }
          }
        }

        // Determine if button is disabled
        final bool isDisabled =
            taskState == TaskState.cooldown ||
            taskState == TaskState.loading ||
            taskState == TaskState.disabled;

        // Determine UI appearance based on state
        final Color gradientStartColor = isDisabled
            ? AppColors.angolaYellow.withValues(alpha: 0.5)
            : AppColors.angolaYellow;
        final Color gradientEndColor = isDisabled
            ? AppColors.orange.withValues(alpha: 0.5)
            : AppColors.orange;

        return PressableScaleWidget(
          onTap: isDisabled ? null : () => taskController.completeTask(),
          scaleFactor: 0.9,
          child: Container(
            padding: ResponsiveUtils.pSymmetric(horizontal: 28, vertical: 14),
            decoration: ShapeDecoration(
              shape: StarBorder(
                points: 10,
                innerRadiusRatio: 0.7,
                pointRounding: 0.3,
                side: BorderSide(
                  color: AppColors.angolaYellow.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              gradient: LinearGradient(
                colors: [gradientStartColor, gradientEndColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shadows: [
                BoxShadow(
                  color: AppColors.glowYellow.withValues(
                    alpha: isDisabled ? 0.3 : 0.7,
                  ),
                  blurRadius: 15,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: taskState == TaskState.loading
                ?
                  // Show loading indicator when in loading state
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14.s,
                        height: 14.s,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.angolaBlack.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.s),
                      Text(
                        buttonText,
                        style: TextStyle(
                          color: AppColors.angolaBlack,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.f,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                :
                  // Regular text for other states
                  Text(
                    buttonText,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.f,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildGameArea(User user, WidgetRef ref) {
    // Get missions from provider
    final missionState = ref.watch(activeMissionProvider);
    // Just pick the first one for now as "Next Available"
    final nextMission = missionState.currentMission;

    return Padding(
      padding: ResponsiveUtils.pSymmetric(horizontal: 15.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 0),
              child: Column(children: [StatsContainer(user: user)]),
            ),
          ),
          Positioned(
            key: _leftTasksKey,
            left: 0,
            top: 100.h,
            bottom: 160.h,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // USAGE 1: Daily Tap Button
                  CooldownTaskButton(
                    taskId: 'daily_tap',
                    icon: FontAwesomeIcons.handPointer,
                    label: ref.t(LocalizationKeys.dailyTap),
                    onTap: (controller) => controller.completeTask(),
                  ),
                  SizedBox(height: 15.s),

                  // USAGE 2: Watch Ad Button
                  CooldownTaskButton(
                    taskId: 'watch_ad',
                    icon: FontAwesomeIcons.circlePlay,
                    label: ref.t(LocalizationKeys.watchAd),
                    actionLoadingLabel: ref.t(LocalizationKeys.loadingAd),
                    onTap: (controller) async {
                      final adMobService = AdMobService();
                      if (!adMobService.isAdLoaded) {
                        await adMobService.loadRewardedAd();
                      }
                      if (!mounted) return;

                      if (!adMobService.isAdLoaded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ref.t(LocalizationKeys.adNotReadyTryAgain),
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      final adWatched = await adMobService.showRewardedAd();
                      if (adWatched) {
                        await controller.completeTask();
                      }
                    },
                  ),
                  SizedBox(height: 15.s),

                  // USAGE 3: Quiz Button
                  CooldownTaskButton(
                    taskId: 'quiz_game',
                    icon: FontAwesomeIcons.questionCircle,
                    label: ref.t(LocalizationKeys.quiz),
                    onTap: (controller) async {
                      // Navigate to quiz and wait for the result
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const QuizScreen()),
                      );

                      // The quiz screen should update the globalQuizResult
                      // which we can then use as the payload.
                      // Only complete task if user submitted an answer (globalQuizResult is non-null)
                      if (globalQuizResult != null) {
                        Map<String, dynamic> payload = globalQuizResult!
                            .toJson();

                        // Complete the task with the quiz result payload
                        await controller.completeTask(payload: payload);

                        // Clear the global result after sending to server
                        globalQuizResult = null;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            key: _rightFeaturesKey,
            right: 0,
            top: 100.h,
            bottom: 160.h,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AccessControlledWidget(
                    featureId: 'land_page',
                    onTap: () {
                      AdHelper.showInterstitialOnNavigation();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LandMapScreen(),
                        ),
                      );
                    },
                    child: _actionButton(
                      FontAwesomeIcons.mapMarkedAlt,
                      ref.t(LocalizationKeys.land),
                    ),
                  ),
                  SizedBox(height: 15.s),
                  PressableScaleWidget(
                    onTap: () {
                      AdHelper.showInterstitialOnNavigation();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SafeLockScreen(),
                        ),
                      );
                    },
                    child: _actionButton(
                      FontAwesomeIcons.lock,
                      ref.t(LocalizationKeys.safeLock),
                    ),
                  ),
                  SizedBox(height: 15.s),
                  PressableScaleWidget(
                    onTap: () {
                      AdHelper.showInterstitialOnNavigation();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EventsScreen()),
                      );
                    },
                    child: _actionButton(
                      FontAwesomeIcons.calendarAlt,
                      ref.t(LocalizationKeys.events),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // NOTE: Main "Tap"/"Tocar" button temporarily disabled for Home screen
          // Uncomment the line below to re-enable the central tap button functionality
          // _buildMainTapButton(),
          Positioned(bottom: 180.h, child: _buildDailyRewardButton()),
          if (nextMission != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: MissionCard(mission: nextMission),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainTapButton() {
    return Consumer(
      builder: (context, ref, child) {
        return const _MainTapButton();
      },
    );
  }

  Widget _actionButton(IconData icon, String label, {VoidCallback? onTap}) {
    // If onTap is provided, wrap with PressableScaleWidget, otherwise return raw widget
    final buttonContent = GlassContainer(
      borderRadius: 16,
      child: SizedBox(
        width: 64.s,
        height: 64.s,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 24.s, color: AppColors.textGrey),
            SizedBox(height: 4.s),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.f,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return PressableScaleWidget(onTap: onTap, child: buttonContent);
    }

    return buttonContent;
  }
}

class _AnimatedGlowingHeart extends StatefulWidget {
  const _AnimatedGlowingHeart();

  @override
  State<_AnimatedGlowingHeart> createState() => _AnimatedGlowingHeartState();
}

class _AnimatedGlowingHeartState extends State<_AnimatedGlowingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 10.0,
      end: 25.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return FaIcon(
          FontAwesomeIcons.heart,
          size: 80.s,
          color: AppColors.angolaYellow,
          shadows: [
            Shadow(
              color: AppColors.glowYellow,
              blurRadius: _glowAnimation.value,
            ),
            Shadow(
              color: AppColors.angolaYellow.withValues(alpha: 0.5),
              blurRadius: _glowAnimation.value * 1.5,
            ),
          ],
        );
      },
    );
  }
}

class _MainTapButton extends ConsumerStatefulWidget {
  const _MainTapButton();

  @override
  ConsumerState<_MainTapButton> createState() => _MainTapButtonState();
}

class _MainTapButtonState extends ConsumerState<_MainTapButton> {
  DateTime? _lastTapTime;
  static const Duration _rateLimitDuration = Duration(
    milliseconds: 250,
  ); // 1 tap per 250ms max

  bool get _isRateLimited {
    if (_lastTapTime == null) return false;
    return DateTime.now().difference(_lastTapTime!) < _rateLimitDuration;
  }

  @override
  Widget build(BuildContext context) {
    final tappingStatusAsync = ref.watch(tappingStatusProvider);
    final tappingStatusNotifier = ref.read(tappingStatusProvider.notifier);

    return tappingStatusAsync.when(
      data: (tappingStatus) {
        final hasReachedDailyLimit = tappingStatusNotifier.hasReachedDailyLimit;

        String displayText = ref.t(LocalizationKeys.tap);
        if (hasReachedDailyLimit) {
          if (tappingStatus.nextResetAt != null) {
            // Use server time for accurate countdown
            final serverTime = ref
                .read(serverTimeProvider.notifier)
                .currentServerTime;
            final timeUntilReset = tappingStatus.nextResetAt!.difference(
              serverTime,
            );

            if (timeUntilReset.isNegative) {
              // Reset time has passed, refresh status
              Future.microtask(() => tappingStatusNotifier.refreshStatus());
              displayText = ref.t(LocalizationKeys.tap);
            } else {
              // Show time until reset
              final hours = timeUntilReset.inHours;
              final minutes = timeUntilReset.inMinutes % 60;
              if (hours > 0) {
                displayText = 'Resets in ${hours}h ${minutes}m';
              } else {
                displayText = 'Resets in ${minutes}m';
              }
            }
          } else {
            displayText = 'Daily limit reached';
          }
        }

        return PressableScaleWidget(
          onTap: hasReachedDailyLimit
              ? null
              : () {
                  // Check rate limit before allowing tap (1 tap per 250ms max)
                  if (!_isRateLimited) {
                    // Give immediate visual and audio feedback
                    SoundService().playEarnCoins();
                    // Update last tap time
                    _lastTapTime = DateTime.now();

                    // Add tap to the tapping system
                    ref.read(tappingControllerProvider).addTap();
                  }
                },
          child: GlassContainer(
            borderRadius: 64.r,
            child: SizedBox(
              width: 160.s,
              height: 160.s,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.coins,
                    size: 50.s,
                    color: hasReachedDailyLimit
                        ? AppColors.textGrey.withValues(alpha: 0.5)
                        : AppColors.angolaYellow,
                    shadows: hasReachedDailyLimit
                        ? const []
                        : [
                            const Shadow(
                              color: AppColors.glowYellow,
                              blurRadius: 15,
                            ),
                          ],
                  ),
                  SizedBox(height: 10.s),
                  Text(
                    displayText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: hasReachedDailyLimit ? 12.f : 18.f,
                      letterSpacing: 1,
                      color: hasReachedDailyLimit
                          ? AppColors.textGrey.withValues(alpha: 0.5)
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => GlassContainer(
        borderRadius: 64.r,
        child: SizedBox(
          width: 160.s,
          height: 160.s,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.angolaYellow),
          ),
        ),
      ),
      error: (error, stack) {
        // On error, allow tapping but refresh status
        Future.microtask(() => tappingStatusNotifier.refreshStatus());

        return PressableScaleWidget(
          onTap: () {
            if (!_isRateLimited) {
              SoundService().playEarnCoins();
              _lastTapTime = DateTime.now();
              ref.read(tappingControllerProvider).addTap();
            }
          },
          child: GlassContainer(
            borderRadius: 64.r,
            child: SizedBox(
              width: 160.s,
              height: 160.s,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.coins,
                    size: 50.s,
                    color: AppColors.angolaYellow,
                    shadows: const [
                      Shadow(color: AppColors.glowYellow, blurRadius: 15),
                    ],
                  ),
                  SizedBox(height: 10.s),
                  Text(
                    ref.t(LocalizationKeys.tap),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.f,
                      letterSpacing: 1,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
