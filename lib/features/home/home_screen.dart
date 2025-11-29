import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/quiz_result.dart';

import 'package:hustlecoin/data/models/user.dart';
import 'package:hustlecoin/features/land/land_map_screen.dart';
import 'package:hustlecoin/features/leaderboard/leaderboard_screen.dart';
import 'package:hustlecoin/features/payout/payout_screen.dart';
import 'package:hustlecoin/features/profile/edit_profile.dart';
import 'package:hustlecoin/features/quiz/quiz_screen.dart';

import 'package:hustlecoin/providers/time_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/providers/tapping_provider.dart';
import 'package:hustlecoin/services/admob_service.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/widgets/banner_ad_widget.dart';
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
  final user = ref.watch(userControllerProvider).value;
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
    final user = ref.read(userControllerProvider).value;
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
      // The UserController handles refetching even on failure.
      // We just need to catch the error here so it doesn't propagate
      // as an unhandled exception in the UI.
      print('Task completion failed, but user state will be updated: $e');
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

  // Method to toggle language between EN and PT
  Future<void> _toggleLanguage(String currentLanguage) async {
    final newLanguage = currentLanguage.toLowerCase() == 'en' ? 'pt' : 'en';
    final userController = ref.read(userControllerProvider.notifier);
    try {
      await userController.updateProfile(language: newLanguage);
      // Show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language updated to ${newLanguage.toUpperCase()}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update language: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
            .push(MaterialPageRoute(builder: (_) => LeaderboardScreen()))
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
        // Settings - no page created yet, just update state
        setState(() {
          _activeNavIndex = index;
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
    final user = userState.value;

    if (userState.isLoading || user == null) {
      return const Scaffold(
        backgroundColor: AppColors.angolaBlack,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ScreenBackground(
        imagePath:
            'assets/images/${HustleUtils.getCurrentHustleKey(user.currentHustle)}.png',
        child: SafeArea(
          child: Column(
            children: [
              // Banner ad at the top
              BannerAdWidget(
                margin: ResponsiveUtils.pSymmetric(horizontal: 15, vertical: 5),
              ),
              TopBar(user: user, onToggleLanguage: _toggleLanguage),
              Text(
                ref.t(LocalizationKeys.hustleCoin),
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14.f,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                ),
              ),
              Expanded(child: _buildGameArea(user)),
              UpgradesSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        activeIndex: _activeNavIndex,
        onNavItemTapped: _onNavItemTapped,
        onGetPaidTapped: _onGetPaidTapped,
      ),
    );
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

  Widget _buildGameArea(User user) {
    return Padding(
      padding: ResponsiveUtils.pSymmetric(horizontal: 15.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 20.s),
              child: StatsContainer(user: user),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
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
                        Map<String, dynamic> payload = globalQuizResult!.toJson();

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
            right: 0,
            top: 0,
            bottom: 0,
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
                  _actionButton(
                    FontAwesomeIcons.calendarAlt,
                    ref.t(LocalizationKeys.events),
                  ),
                ],
              ),
            ),
          ),
          _buildMainTapButton(),
          Positioned(bottom: 100.s, child: _buildDailyRewardButton()),
        ],
      ),
    );
  }

  Widget _buildMainTapButton() {
    return Consumer(
      builder: (context, ref, child) {
        return _MainTapButton();
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
      return PressableScaleWidget(
        onTap: onTap,
        child: buttonContent,
      );
    }
    
    return buttonContent;
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
    milliseconds: 1000,
  ); // 1 tap per second max

  bool get _isRateLimited {
    if (_lastTapTime == null) return false;
    return DateTime.now().difference(_lastTapTime!) < _rateLimitDuration;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider).value;
    final hasReachedDailyLimit = (user?.dailyTapEarnings ?? 0) >= 200;

    return PressableScaleWidget(
      onTap: hasReachedDailyLimit
          ? null
          : () {
              // Check rate limit before allowing tap (1 tap per second max)
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
                    ? []
                    : [
                        Shadow(
                          color: AppColors.glowYellow.withValues(alpha: 0.8),
                          blurRadius: 15,
                        ),
                      ],
              ),
              SizedBox(height: 10.s),
              Text(
                hasReachedDailyLimit
                    ? 'Daily limit reached'
                    : ref.t(LocalizationKeys.tap),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: hasReachedDailyLimit ? 14.f : 18.f,
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
  }
}
