import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/quiz_result.dart';
import 'package:hustlecoin/data/models/user.dart';
import 'package:hustlecoin/features/land/land_map_screen.dart';
import 'package:hustlecoin/features/leaderboard/leaderboard_screen.dart';
import 'package:hustlecoin/features/level_up/select_hustle_screen.dart';
import 'package:hustlecoin/features/profile/edit_profile.dart';
import 'package:hustlecoin/features/quiz/quiz_screen.dart';
import 'package:hustlecoin/features/shop/shop_screen.dart';
import 'package:hustlecoin/providers/foundational_providers.dart';
import 'package:hustlecoin/providers/time_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/providers/user_specific_data_provider.dart';
import 'package:hustlecoin/services/admob_service.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/widgets/banner_ad_widget.dart';
import 'package:hustlecoin/utils/ad_helper.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'dart:async'; // For Timer
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:hustlecoin/widgets/screen_background.dart';

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
      SoundService().playEarnCoins();

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
              _buildTopBar(user),
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
              _buildUpgradesSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopBar(User user) {
    return Padding(
      padding: ResponsiveUtils.pSymmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassContainer(
            borderRadius: 12,
            child: Padding(
              padding: ResponsiveUtils.p(8.0),
              child: Row(
                children: [
                  Container(
                    width: 38.s,
                    height: 38.s,
                    margin: EdgeInsets.only(right: 8.s),
                    decoration: BoxDecoration(
                      color: AppColors.angolaRed,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.glowRed,
                          blurRadius: 8,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: Icon(
                      FontAwesomeIcons.star,
                      size: 18.s,
                      color: AppColors.textLight,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.hcBalance} HC',
                        style: TextStyle(
                          fontSize: 16.f,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '≈ Kz ${user.kzBalance}',
                        style: TextStyle(
                          fontSize: 12.f,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12.s),
                ],
              ),
            ),
          ),
          Container(
            width: 54.s,
            height: 54.s,
            padding: ResponsiveUtils.p(3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.angolaYellow, AppColors.angolaRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: GlassContainer(
              borderRadius: 13,
              child: Icon(FontAwesomeIcons.user, size: 28.s),
            ),
          ),
          PressableScaleWidget(
            onTap: () => _toggleLanguage(user.language),
            soundType:
                SoundType.switchSound, // Use switch sound for language toggle
            child: GlassContainer(
              borderRadius: 12,
              child: Padding(
                padding: ResponsiveUtils.pSymmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: ResponsiveUtils.pSymmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: user.language.toUpperCase() == 'EN'
                            ? AppColors.angolaYellow
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'EN',
                        style: TextStyle(
                          color: user.language.toUpperCase() == 'EN'
                              ? AppColors.angolaBlack
                              : AppColors.textGrey,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.f,
                        ),
                      ),
                    ),
                    Container(
                      padding: ResponsiveUtils.pSymmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: user.language.toUpperCase() == 'PT'
                            ? AppColors.angolaYellow
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'PT',
                        style: TextStyle(
                          color: user.language.toUpperCase() == 'PT'
                              ? AppColors.angolaBlack
                              : AppColors.textGrey,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.f,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            ? AppColors.angolaYellow.withOpacity(0.5)
            : AppColors.angolaYellow;
        final Color gradientEndColor = isDisabled
            ? AppColors.orange.withOpacity(0.5)
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
                  color: AppColors.angolaYellow.withOpacity(0.5),
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
                  color: AppColors.glowYellow.withOpacity(
                    isDisabled ? 0.3 : 0.7,
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
                            AppColors.angolaBlack.withOpacity(0.7),
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
              child: _StatsContainer(user: user),
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
                    icon:
                        FontAwesomeIcons.questionCircle, // A more fitting icon
                    label: ref.t(LocalizationKeys.quiz),
                    onTap: (controller) async {
                      // Navigate to quiz and wait for the result
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const QuizScreen()),
                      );

                      // The quiz screen should update the globalQuizResult
                      // which we can then use as the payload.
                      Map<String, dynamic> payload =
                          globalQuizResult?.toJson() ?? {};

                      // Complete the task with the quiz result payload
                      await controller.completeTask(payload: payload);
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
                  _actionButton(
                    FontAwesomeIcons.mapMarkedAlt,
                    ref.t(LocalizationKeys.land),
                    onTap: () {
                      AdHelper.showInterstitialOnNavigation();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LandMapScreen(),
                        ),
                      );
                    },
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
        final taskState = ref.watch(taskStateProvider('quick_tap'));
        final taskController = TaskController(ref, 'quick_tap');
        return _MainTapButton(
          taskState: taskState,
          taskController: taskController,
        );
      },
    );
  }

  Widget _actionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return PressableScaleWidget(
      onTap: onTap ?? () {},
      child: GlassContainer(
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
      ),
    );
  }

  Widget _buildUpgradesSection() {
    return Padding(
      padding: ResponsiveUtils.pLTRB(15, 10, 15, 10),
      child: ClipRect(
        child: Row(
          children: [
            _upgradeItem(
              FontAwesomeIcons.robot,
              ref.t(LocalizationKeys.chatBot),
            ),
            SizedBox(width: 8.s),
            _upgradeItem(
              FontAwesomeIcons.rocket,
              ref.t(LocalizationKeys.boosts),
              onTap: () {
                AdHelper.showInterstitialOnNavigation();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ShopScreen(itemTypeFilter: 'BOOSTER'),
                  ),
                );
              },
            ),
            SizedBox(width: 8.s),
            _upgradeItem(
              FontAwesomeIcons.key,
              ref.t(LocalizationKeys.keys),
              onTap: () {
                AdHelper.showInterstitialOnNavigation();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const ShopScreen(itemTypeFilter: 'ACCESS_KEY'),
                  ),
                );
              },
            ),
            SizedBox(width: 8.s),
            _upgradeItem(
              FontAwesomeIcons.store,
              ref.t(LocalizationKeys.shop),
              isShop: true,
              onTap: () {
                AdHelper.showInterstitialOnNavigation();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ShopScreen(
                      excludeTypes: ["ACCESS_KEY", "BOOSTER"],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _upgradeItem(
    IconData icon,
    String label, {
    bool isShop = false,
    VoidCallback? onTap,
  }) {
    Widget content;
    if (isShop) {
      content = Container(
        height: 65.s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: const LinearGradient(
            colors: [AppColors.angolaYellow, AppColors.angolaRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.glowRed,
              blurRadius: 20,
              spreadRadius: -5,
            ),
          ],
        ),
        child: _upgradeItemContent(icon, label, AppColors.textLight),
      );
    } else {
      content = GlassContainer(
        borderRadius: 12,
        child: SizedBox(
          height: 65.s,
          child: _upgradeItemContent(icon, label, AppColors.textGrey),
        ),
      );
    }
    return Expanded(
      child: PressableScaleWidget(onTap: onTap ?? () {}, child: content),
    );
  }

  Widget _upgradeItemContent(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(icon, size: 22.s, color: color),
        SizedBox(height: 4.s),
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.f,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return GlassContainer(
      borderRadius: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        child: Padding(
          padding: ResponsiveUtils.pLTRB(0, 8, 0, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(FontAwesomeIcons.house, ref.t(LocalizationKeys.home), 0),
              _navItem(
                FontAwesomeIcons.chartLine,
                ref.t(LocalizationKeys.leaderboard),
                1,
              ),
              _navItem(
                FontAwesomeIcons.userCircle,
                ref.t(LocalizationKeys.profile),
                2,
              ),
              _navItem(
                FontAwesomeIcons.cog,
                ref.t(LocalizationKeys.settings),
                3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isActive = _activeNavIndex == index;
    final color = isActive ? AppColors.angolaYellow : AppColors.textGrey;
    final shadows = isActive
        ? [Shadow(color: AppColors.glowYellow, blurRadius: 10)]
        : <Shadow>[];

    return Expanded(
      child: InkWell(
        onTap: () {
          // Play click sound before navigation
          SoundService().playClick();
          _onNavItemTapped(index);
        },
        customBorder: const CircleBorder(),
        splashColor: AppColors.angolaYellow.withOpacity(0.15),
        highlightColor: AppColors.angolaYellow.withOpacity(0.1),
        child: Padding(
          padding: ResponsiveUtils.pSymmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(icon, size: 22.s, color: color, shadows: shadows),
              SizedBox(height: 4.s),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.f,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: color,
                  shadows: shadows,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsContainer extends ConsumerWidget {
  final User user;
  const _StatsContainer({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelStatusAsync = ref.watch(levelStatusProvider);
    const textShadow = [
      Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(1, 1)),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ref.t(LocalizationKeys.hustleLevel),
                style: TextStyle(
                  fontSize: 12.f,
                  color: AppColors.textGrey,
                  shadows: textShadow,
                ),
              ),
              Text(
                HustleUtils.getCurrentHustleDisplayName(user.currentHustle),
                style: TextStyle(
                  fontSize: 20.f,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  shadows: textShadow,
                ),
              ),
              Text(
                '${ref.t(LocalizationKeys.level)} ${user.level}',
                style: TextStyle(
                  fontSize: 12.f,
                  color: AppColors.textGrey,
                  shadows: textShadow,
                ),
              ),
              SizedBox(height: 12.s),
              Text(
                '${ref.t(LocalizationKeys.dailyStreak)}: ${user.dailyStreak}',
                style: TextStyle(
                  fontSize: 12.f,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w600,
                  shadows: textShadow,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 15.s),
        Expanded(
          child: levelStatusAsync.when(
            data: (status) {
              if (status == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ref.t(LocalizationKeys.nextLevel),
                      style: TextStyle(
                        fontSize: 12.f,
                        color: AppColors.textGrey,
                        shadows: textShadow,
                      ),
                    ),
                    SizedBox(height: 4.s),
                    Text("${ref.t(LocalizationKeys.statsLoading)}"),
                  ],
                );
              }
              final progress = status.hcEarnedInLevelProgress.toDouble();
              final required = status.hcEarnedInLevelRequired.toDouble();
              final progressValue = required > 0
                  ? (progress / required).clamp(0.0, 1.0)
                  : 0.0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ref.t(LocalizationKeys.nextLevel),
                    style: TextStyle(
                      fontSize: 12.f,
                      color: AppColors.textGrey,
                      shadows: textShadow,
                    ),
                  ),
                  SizedBox(height: 4.s),
                  GlassContainer(
                    borderRadius: 6,
                    child: Container(
                      width: double.infinity,
                      height: 12.s,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            status.isEligibleForUpgrade
                                ? Colors.green.shade500
                                : AppColors.angolaYellow,
                          ),
                          minHeight: 12.s,
                          color: AppColors.angolaRed,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.s),
                  Text(
                    '${status.hcEarnedInLevelProgress} / ${status.hcEarnedInLevelRequired} HC',
                    style: TextStyle(
                      fontSize: 11.f,
                      color: AppColors.textGrey,
                      shadows: textShadow,
                    ),
                  ),
                  SizedBox(height: 12.s),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: status.isEligibleForUpgrade
                                  ? AppColors.glowYellow
                                  : AppColors.orange.withOpacity(0.3),
                              blurRadius: status.isEligibleForUpgrade ? 15 : 10,
                              spreadRadius: status.isEligibleForUpgrade
                                  ? 0
                                  : -2,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: _UpgradeButtonAnimator(
                          isEnabled: status.isEligibleForUpgrade,
                          child: PressableScaleWidget(
                            onTap: status.isEligibleForUpgrade
                                ? () async {
                                    try {
                                      // Show loading state
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            ref.t(
                                              LocalizationKeys
                                                  .processingLevelUpgrade,
                                            ),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );

                                      // Call the level upgrade API
                                      final apiRepo = ref.read(
                                        apiRepositoryProvider,
                                      );
                                      final result = await apiRepo
                                          .levelUpgrade();

                                      // Extract the new level and hustle
                                      final int newLevel = result['new_level'];
                                      final dynamic newHustleObj =
                                          result['new_hustle'];
                                      // Extract the hustle key (English name) for the background image
                                      final String newHustleKey =
                                          HustleUtils.getCurrentHustleKey(
                                            newHustleObj,
                                          );

                                      // Navigate to the hustle selection screen
                                      if (context.mounted) {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => SelectHustleScreen(
                                              newLevel: newLevel,
                                              newHustle: newHustleKey,
                                            ),
                                          ),
                                        );
                                      }

                                      // Refresh user data and level status
                                      ref.invalidate(userControllerProvider);
                                      ref.invalidate(levelStatusProvider);
                                    } catch (e) {
                                      // Show error message
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: status.isEligibleForUpgrade
                                    ? AppColors.angolaYellow
                                    : AppColors.orange,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: ResponsiveUtils.pSymmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              child: Text(
                                '${status.upgradeFee} HC',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.f,
                                  color: AppColors.angolaBlack,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.s),
                      Text(
                        ref.t(LocalizationKeys.upgradeLevel),
                        style: TextStyle(
                          fontSize: 10.f,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                          shadows: textShadow,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, st) => const Center(child: Text("Error")),
          ),
        ),
      ],
    );
  }
}

// Main Tap Button Widget
class _MainTapButton extends ConsumerWidget {
  final TaskState taskState;
  final TaskController taskController;

  const _MainTapButton({required this.taskState, required this.taskController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDisabled =
        taskState == TaskState.cooldown ||
        taskState == TaskState.loading ||
        taskState == TaskState.disabled;

    return PressableScaleWidget(
      onTap: isDisabled
          ? null
          : () {
              taskController.completeTask();
            },
      child: GlassContainer(
        child: SizedBox(
          width: 160.s,
          height: 160.s,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (taskState == TaskState.loading)
                SizedBox(
                  width: 50.s,
                  height: 50.s,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.angolaYellow,
                    ),
                  ),
                )
              else
                FaIcon(
                  FontAwesomeIcons.coins,
                  size: 50.s,
                  color: isDisabled
                      ? AppColors.textGrey.withOpacity(0.5)
                      : AppColors.angolaYellow,
                  shadows: isDisabled
                      ? []
                      : [
                          Shadow(
                            color: AppColors.glowYellow.withOpacity(0.8),
                            blurRadius: 15,
                          ),
                        ],
                ),
              SizedBox(height: 10.s),
              Text(
                ref.t(LocalizationKeys.tap),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18.f,
                  letterSpacing: 1,
                  color: isDisabled
                      ? AppColors.textGrey.withOpacity(0.5)
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

// Animated upgrade button wrapper
class _UpgradeButtonAnimator extends StatefulWidget {
  final Widget child;
  final bool isEnabled;

  const _UpgradeButtonAnimator({required this.child, required this.isEnabled});

  @override
  State<_UpgradeButtonAnimator> createState() => _UpgradeButtonAnimatorState();
}

class _UpgradeButtonAnimatorState extends State<_UpgradeButtonAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_UpgradeButtonAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start or stop the animation based on enabled state
    if (widget.isEnabled && !oldWidget.isEnabled) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isEnabled && oldWidget.isEnabled) {
      _animationController.stop();
      _animationController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: widget.child,
    );
  }
}

/// A reusable button for tasks that have a cooldown period.
///
/// This widget manages its own state for the cooldown timer, progress
/// indicator, and loading states, based on the provided [taskId].
class CooldownTaskButton extends ConsumerStatefulWidget {
  /// The unique identifier for the task.
  final String taskId;

  /// The icon to display when the button is in its default, available state.
  final IconData icon;

  /// The text label to display below the icon.
  final String label;

  /// Optional text to display when the custom [onTap] action is in progress.
  final String? actionLoadingLabel;

  /// The asynchronous callback function to execute when the button is tapped.
  /// It receives a [TaskController] instance to allow the action to complete
  /// the task on the backend.
  final Future<void> Function(TaskController controller) onTap;

  const CooldownTaskButton({
    super.key,
    required this.taskId,
    required this.icon,
    required this.label,
    this.actionLoadingLabel,
    required this.onTap,
  });

  @override
  ConsumerState<CooldownTaskButton> createState() => _CooldownTaskButtonState();
}

class _CooldownTaskButtonState extends ConsumerState<CooldownTaskButton> {
  Timer? _cooldownTimer;
  Duration? _remainingTime;
  Duration? _totalCooldownTime;

  // Local state to handle loading for actions that happen before
  // the backend task is called (e.g., showing an ad).
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure ref is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initializeState();
    });
  }

  @override
  void didUpdateWidget(CooldownTaskButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the task ID changes (unlikely but good practice) or the state
    // from the provider changes, we re-initialize.
    _initializeState();
  }

  void _initializeState() {
    final taskState = ref.read(taskStateProvider(widget.taskId));
    if (taskState == TaskState.cooldown) {
      _updateRemainingTime();
      _startCooldownTimer();
    } else {
      _cooldownTimer?.cancel();
    }
  }

  void _updateRemainingTime() {
    final taskController = TaskController(ref, widget.taskId);
    final remaining = taskController.remainingCooldown;
    if (mounted) {
      setState(() {
        _remainingTime = remaining;
        // Store initial total time for progress calculation.
        // This ensures the progress ring starts full.
        if (_totalCooldownTime == null && _remainingTime != null) {
          _totalCooldownTime = _remainingTime;
        }
      });
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _cooldownTimer?.cancel();
        return;
      }
      _updateRemainingTime();

      // If cooldown expires, cancel the timer. The provider will handle the state change.
      if (_remainingTime == null || _remainingTime!.inSeconds <= 0) {
        _cooldownTimer?.cancel();
        // Invalidate the provider to force a state refresh from available->cooldown.
        ref.invalidate(taskStateProvider(widget.taskId));
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create the controller here to ensure it uses the latest ref.
    final taskController = TaskController(ref, widget.taskId);

    // Watch providers for real-time updates.
    final taskState = ref.watch(taskStateProvider(widget.taskId));
    final isLoading = ref.watch(taskLoadingStateProvider(widget.taskId));

    // Determine the current effective state for the UI.
    final bool isApiLoading = isLoading || taskState == TaskState.loading;
    final bool isCooldown = taskState == TaskState.cooldown;

    // The button is disabled if any loading is happening, or it's on cooldown.
    final bool isDisabled = isApiLoading || isCooldown || _isActionInProgress;

    return PressableScaleWidget(
      onTap: isDisabled
          ? null
          : () async {
              if (_isActionInProgress) return;

              setState(() => _isActionInProgress = true);
              try {
                // Execute the custom tap action.
                await widget.onTap(taskController);
              } finally {
                // Ensure the loading state is reset even if an error occurs.
                if (mounted) {
                  setState(() => _isActionInProgress = false);
                }
              }
            },
      child: GlassContainer(
        borderRadius: 16,
        child: SizedBox(
          width: 64.s,
          height: 64.s,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main content (Icon, Text, or Loader)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isApiLoading || _isActionInProgress)
                    SizedBox(
                      width: 24.s,
                      height: 24.s,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.angolaYellow,
                        ),
                      ),
                    )
                  else
                    FaIcon(
                      widget.icon,
                      size: 24.s,
                      color: isCooldown
                          ? AppColors.textGrey.withOpacity(0.5)
                          : AppColors.textGrey,
                    ),
                  SizedBox(height: 4.s),
                  Text(
                    _getButtonText(taskState),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9.f,
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(taskState),
                    ),
                  ),
                ],
              ),

              // Cooldown circular progress overlay
              if (isCooldown &&
                  _remainingTime != null &&
                  _totalCooldownTime != null &&
                  _totalCooldownTime!.inSeconds > 0)
                SizedBox(
                  width: 48.s,
                  height: 48.s,
                  child: CircularProgressIndicator(
                    value:
                        1 -
                        (_remainingTime!.inSeconds.clamp(
                              0,
                              _totalCooldownTime!.inSeconds,
                            ) /
                            _totalCooldownTime!.inSeconds),
                    strokeWidth: 2.5,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.angolaYellow,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getButtonText(TaskState taskState) {
    if (_isActionInProgress) {
      return widget.actionLoadingLabel ?? ref.t(LocalizationKeys.loading);
    }
    if (taskState == TaskState.loading) {
      return ref.t(LocalizationKeys.loading);
    }
    if (taskState == TaskState.cooldown && _remainingTime != null) {
      final minutes = _remainingTime!.inMinutes.remainder(60);
      final seconds = _remainingTime!.inSeconds.remainder(60);
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return widget.label;
  }

  Color _getTextColor(TaskState taskState) {
    if (_isActionInProgress) return AppColors.angolaYellow;

    switch (taskState) {
      case TaskState.available:
        return AppColors.textLight;
      case TaskState.cooldown:
        return AppColors.angolaYellow;
      default:
        return AppColors.textGrey;
    }
  }
}
