// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/state/all_states.dart';
import 'dart:async'; // For Timer
import 'app_colors.dart';
import 'shop.dart';
import 'leaderboard.dart';
import 'edit_profile.dart';
import 'quiz.dart';
import 'land_map.dart';

// A custom, lightweight widget for press feedback.
class PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final BorderRadius borderRadius;

  const PressableWidget({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.95,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<PressableWidget> createState() => _PressableWidgetState();
}

class _PressableWidgetState extends State<PressableWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleFactor : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// Task state management
final taskStateProvider = StateProvider.family<TaskState, String>((
  ref,
  taskId,
) {
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

    // Set task to loading state. The state will automatically update to
    // cooldown or available after the user data is refetched.
    ref.read(taskStateProvider(taskId).notifier).state = TaskState.loading;

    try {
      await ref
          .read(userControllerProvider.notifier)
          .completeTask(taskId, payload: payload);
    } catch (e) {
      // The UserController handles refetching even on failure.
      // We just need to catch the error here so it doesn't propagate
      // as an unhandled exception in the UI.
      print('Task completion failed, but user state will be updated: $e');
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Taxi Driver.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                const Color(0xFF101010).withOpacity(0.4),
                const Color(0xFF101010).withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(user),
                const Text(
                  'Hustle Coin',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
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
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopBar(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassEffectContainer(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.angolaRed,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.glowRed,
                          blurRadius: 8,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      FontAwesomeIcons.star,
                      size: 18,
                      color: AppColors.textLight,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.hcBalance} HC',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '≈ Kz ${user.kzBalance}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.angolaYellow, AppColors.angolaRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _GlassEffectContainer(
              borderRadius: BorderRadius.circular(13),
              child: const Icon(FontAwesomeIcons.user, size: 28),
            ),
          ),
          _GlassEffectContainer(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user.language.toUpperCase() == 'EN'
                          ? AppColors.angolaYellow
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'EN',
                      style: TextStyle(
                        color: user.language.toUpperCase() == 'EN'
                            ? AppColors.angolaBlack
                            : AppColors.textGrey,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user.language.toUpperCase() == 'PT'
                          ? AppColors.angolaYellow
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PT',
                      style: TextStyle(
                        color: user.language.toUpperCase() == 'PT'
                            ? AppColors.angolaBlack
                            : AppColors.textGrey,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
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
    // Determine button text based on state
    String buttonText = 'Daily Reward';
    if (taskState == TaskState.loading) {
      buttonText = 'Loading...';
    } else if (taskState == TaskState.cooldown) {
      // Get the remaining cooldown based on server time
      final remainingTime = taskController.remainingCooldown;
      if (remainingTime != null) {
        // If cooldown time is large (like a day), show hours remaining
        if (remainingTime.inHours > 0) {
          final hours = remainingTime.inHours;
          buttonText = '$hours hrs left';
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

    return PressableWidget(
      onTap: isDisabled ? null : () => taskController.completeTask(),
      scaleFactor: 0.9,
      borderRadius: BorderRadius.circular(30), // Approximates the star shape
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
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
              color: AppColors.glowYellow.withOpacity(isDisabled ? 0.3 : 0.7),
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
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.angolaBlack.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    buttonText,
                    style: const TextStyle(
                      color: AppColors.angolaBlack,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              )
            :
              // Regular text for other states
              Text(
                buttonText,
                style: const TextStyle(
                  color: AppColors.angolaBlack,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildGameArea(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              // *** FIX: Replaced method call with new widget ***
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
                  _buildDailyTapButton(),
                  const SizedBox(height: 15),
                  _actionButton(FontAwesomeIcons.circlePlay, 'Watch Ad'),
                  const SizedBox(height: 15),
                  _buildQuizButton(),
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
                    'Land',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LandMapScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _actionButton(FontAwesomeIcons.calendarAlt, 'Events'),
                ],
              ),
            ),
          ),
          _buildMainTapButton(),
          Positioned(bottom: 120, child: _buildDailyRewardButton()),
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

  Widget _buildDailyTapButton() {
    return Consumer(
      builder: (context, ref, child) {
        final taskState = ref.watch(taskStateProvider('daily_tap'));
        final taskController = TaskController(ref, 'daily_tap');

        return _DailyTapButton(
          taskState: taskState,
          taskController: taskController,
        );
      },
    );
  }

  Widget _buildQuizButton() {
    return Consumer(
      builder: (context, ref, child) {
        // Watch the state directly from the provider.
        final taskState = ref.watch(taskStateProvider('quiz_game'));
        final taskController = TaskController(ref, 'quiz_game');

        return _QuizButton(
          taskState: taskState,
          taskController: taskController,
        );
      },
    );
  }

  Widget _actionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return PressableWidget(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: _GlassEffectContainer(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(icon, size: 24, color: AppColors.textGrey),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
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
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Row(
        children: [
          _upgradeItem(FontAwesomeIcons.robot, 'Chat bot'),
          const SizedBox(width: 8),
          _upgradeItem(
            FontAwesomeIcons.rocket,
            'Boosts',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ShopScreen(itemTypeFilter: 'BOOSTER'),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _upgradeItem(
            FontAwesomeIcons.key,
            'Keys',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const ShopScreen(itemTypeFilter: 'ACCESS_KEY'),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _upgradeItem(
            FontAwesomeIcons.store,
            'Shop',
            isShop: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const ShopScreen(excludeTypes: ["ACCESS_KEY", "BOOSTER"]),
                ),
              );
            },
          ),
        ],
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
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
      content = _GlassEffectContainer(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 65,
          child: _upgradeItemContent(icon, label, AppColors.textGrey),
        ),
      );
    }
    return Expanded(
      child: PressableWidget(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }

  Widget _upgradeItemContent(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return _GlassEffectContainer(
      borderRadius: BorderRadius.zero,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(FontAwesomeIcons.house, 'Home', 0),
              _navItem(FontAwesomeIcons.chartLine, 'Leaderboard', 1),
              _navItem(FontAwesomeIcons.userCircle, 'Profile', 2),
              _navItem(FontAwesomeIcons.cog, 'Settings', 3),
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
        ? [const Shadow(color: AppColors.glowYellow, blurRadius: 10)]
        : <Shadow>[];

    return Expanded(
      child: InkWell(
        onTap: () => _onNavItemTapped(index),
        customBorder: const CircleBorder(),
        splashColor: AppColors.angolaYellow.withOpacity(0.15),
        highlightColor: AppColors.angolaYellow.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(icon, size: 22, color: color, shadows: shadows),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
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

// *** NEW: Extracted widget to solve the error and improve performance ***
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
              const Text(
                'HUSTLE LEVEL',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  shadows: textShadow,
                ),
              ),
              Text(
                user.currentHustle,
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  shadows: textShadow,
                ),
              ),
              Text(
                'Level ${user.level}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  shadows: textShadow,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '🔥 Daily Streak: ${user.dailyStreak}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w600,
                  shadows: textShadow,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: levelStatusAsync.when(
            data: (status) {
              if (status == null) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'NEXT LEVEL',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                        shadows: textShadow,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("Stats loading..."),
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
                  const Text(
                    'NEXT LEVEL',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                      shadows: textShadow,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _GlassEffectContainer(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
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
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            status.isEligibleForUpgrade
                                ? Colors.green.shade500
                                : AppColors.angolaYellow,
                          ),
                          minHeight: 12,
                          color: AppColors.angolaRed,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${status.hcEarnedInLevelProgress} / ${status.hcEarnedInLevelRequired} HC',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                      shadows: textShadow,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _UpgradeButtonAnimator(
                          isEnabled: status.isEligibleForUpgrade,
                          child: PressableWidget(
                            onTap: status.isEligibleForUpgrade
                                ? () {
                                    // Create a task controller for the level_upgrade task
                                    final taskController = TaskController(
                                      ref,
                                      'level_upgrade',
                                    );
                                    taskController.completeTask();
                                  }
                                : null,
                            child: ElevatedButton(
                              onPressed: status.isEligibleForUpgrade
                                  ? () {}
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.angolaYellow,
                                disabledBackgroundColor: AppColors.orange,
                                foregroundColor: AppColors.angolaBlack,
                                disabledForegroundColor: AppColors.angolaBlack,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              child: Text('${status.upgradeFee} HC'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Upgrade Level',
                        style: TextStyle(
                          fontSize: 10,
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

// Daily Tap Button Widget
class _DailyTapButton extends StatefulWidget {
  final TaskState taskState;
  final TaskController taskController;

  const _DailyTapButton({
    required this.taskState,
    required this.taskController,
  });

  @override
  State<_DailyTapButton> createState() => _DailyTapButtonState();
}

class _DailyTapButtonState extends State<_DailyTapButton> {
  Timer? _cooldownTimer;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();

    // Start the timer if on cooldown
    if (widget.taskState == TaskState.cooldown) {
      _startCooldownTimer();
    }
  }

  @override
  void didUpdateWidget(_DailyTapButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.taskState != oldWidget.taskState) {
      _updateRemainingTime();

      // Start or cancel timer based on the new state
      if (widget.taskState == TaskState.cooldown) {
        _startCooldownTimer();
      } else {
        _cooldownTimer?.cancel();
      }
    }
  }

  void _updateRemainingTime() {
    if (widget.taskState == TaskState.cooldown) {
      setState(() {
        // Get the remaining cooldown based on server time
        _remainingTime = widget.taskController.remainingCooldown;
      });
    } else {
      _remainingTime = null;
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    // Update every second, but the actual time is based on server time
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          // Get the remaining cooldown based on server time
          _remainingTime = widget.taskController.remainingCooldown;

          // Cancel timer if cooldown has expired
          if (_remainingTime == null || _remainingTime!.inSeconds <= 0) {
            _cooldownTimer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String get _buttonText {
    switch (widget.taskState) {
      case TaskState.loading:
        return 'LOADING';
      case TaskState.cooldown:
        final minutes = _remainingTime?.inMinutes.remainder(60) ?? 0;
        final seconds = _remainingTime?.inSeconds.remainder(60) ?? 0;
        return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      default:
        return 'DAILY TAP';
    }
  }

  Color get _textColor {
    switch (widget.taskState) {
      case TaskState.available:
        return AppColors.textLight;
      case TaskState.cooldown:
        return AppColors.angolaYellow;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled =
        widget.taskState == TaskState.cooldown ||
        widget.taskState == TaskState.loading ||
        widget.taskState == TaskState.disabled;

    return PressableWidget(
      onTap: isDisabled ? null : () => widget.taskController.completeTask(),
      borderRadius: BorderRadius.circular(16),
      child: _GlassEffectContainer(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.taskState == TaskState.loading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.angolaYellow,
                        ),
                      ),
                    )
                  else
                    FaIcon(
                      FontAwesomeIcons.handPointer,
                      size: 24,
                      color: isDisabled
                          ? AppColors.textGrey.withOpacity(0.5)
                          : AppColors.textGrey,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _buttonText,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                ],
              ),

              // Cooldown overlay
              if (widget.taskState == TaskState.cooldown &&
                  _remainingTime != null)
                CircularProgressIndicator(
                  value:
                      1 -
                      (_remainingTime!.inSeconds /
                          (widget.taskController.isOnCooldown
                              ? widget
                                        .taskController
                                        .remainingCooldown!
                                        .inSeconds +
                                    _remainingTime!.inSeconds
                              : _remainingTime!.inSeconds)),
                  strokeWidth: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.angolaYellow,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

//
//
//
//

class _QuizButton extends StatefulWidget {
  final TaskState taskState;
  final TaskController taskController;

  const _QuizButton({required this.taskState, required this.taskController});

  @override
  State<_QuizButton> createState() => _QuizButtonState();
}

class _QuizButtonState extends State<_QuizButton> {
  Timer? _cooldownTimer;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();

    // Start the timer if on cooldown
    if (widget.taskState == TaskState.cooldown) {
      _startCooldownTimer();
    }
  }

  @override
  void didUpdateWidget(_QuizButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.taskState != oldWidget.taskState) {
      _updateRemainingTime();

      // Start or cancel timer based on the new state
      if (widget.taskState == TaskState.cooldown) {
        _startCooldownTimer();
      } else {
        _cooldownTimer?.cancel();
      }
    }
  }

  void _updateRemainingTime() {
    if (widget.taskState == TaskState.cooldown) {
      setState(() {
        // Get the remaining cooldown based on server time
        _remainingTime = widget.taskController.remainingCooldown;
      });
    } else {
      _remainingTime = null;
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    // Update every second, but the actual time is based on server time
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          // Get the remaining cooldown based on server time
          _remainingTime = widget.taskController.remainingCooldown;

          // Cancel timer if cooldown has expired
          if (_remainingTime == null || _remainingTime!.inSeconds <= 0) {
            _cooldownTimer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String get _buttonText {
    switch (widget.taskState) {
      case TaskState.loading:
        return 'LOADING';
      case TaskState.cooldown:
        final minutes = _remainingTime?.inMinutes.remainder(60) ?? 0;
        final seconds = _remainingTime?.inSeconds.remainder(60) ?? 0;
        return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      default:
        return 'QUIZ';
    }
  }

  Color get _textColor {
    switch (widget.taskState) {
      case TaskState.available:
        return AppColors.textLight;
      case TaskState.cooldown:
        return AppColors.angolaYellow;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled =
        widget.taskState == TaskState.cooldown ||
        widget.taskState == TaskState.loading ||
        widget.taskState == TaskState.disabled;

    return PressableWidget(
      onTap: isDisabled
          ? null
          : () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const QuizScreen()));

              Map<String, dynamic> payload = globalQuizResult?.toJson() ?? {};
              widget.taskController.completeTask(payload: payload);
            },
      borderRadius: BorderRadius.circular(16),
      child: _GlassEffectContainer(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.taskState == TaskState.loading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.angolaYellow,
                        ),
                      ),
                    )
                  else
                    FaIcon(
                      FontAwesomeIcons.handPointer,
                      size: 24,
                      color: isDisabled
                          ? AppColors.textGrey.withOpacity(0.5)
                          : AppColors.textGrey,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _buttonText,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                ],
              ),

              // Cooldown overlay
              if (widget.taskState == TaskState.cooldown &&
                  _remainingTime != null)
                CircularProgressIndicator(
                  value:
                      1 -
                      (_remainingTime!.inSeconds /
                          (widget.taskController.isOnCooldown
                              ? widget
                                        .taskController
                                        .remainingCooldown!
                                        .inSeconds +
                                    _remainingTime!.inSeconds
                              : _remainingTime!.inSeconds)),
                  strokeWidth: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.angolaYellow,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

//
//
//
//
//
//
//

// Main Tap Button Widget
class _MainTapButton extends StatelessWidget {
  final TaskState taskState;
  final TaskController taskController;

  const _MainTapButton({required this.taskState, required this.taskController});

  @override
  Widget build(BuildContext context) {
    final bool isDisabled =
        taskState == TaskState.cooldown ||
        taskState == TaskState.loading ||
        taskState == TaskState.disabled;

    return PressableWidget(
      onTap: isDisabled
          ? null
          : () {
              taskController.completeTask();
            },
      borderRadius: BorderRadius.circular(80),
      child: _GlassEffectContainer(
        isCircle: true,
        child: SizedBox(
          width: 160,
          height: 160,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (taskState == TaskState.loading)
                const SizedBox(
                  width: 50,
                  height: 50,
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
                  size: 50,
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
              const SizedBox(height: 10),
              Text(
                'TAP',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
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

// HIGH-PERFORMANCE VERSION: No blur, just a semi-transparent container.
class _GlassEffectContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final bool isCircle;

  const _GlassEffectContainer({
    required this.child,
    this.borderRadius,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : borderRadius,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: child,
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
