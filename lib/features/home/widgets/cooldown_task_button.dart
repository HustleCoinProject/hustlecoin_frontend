// lib/widgets/cooldown_task_button.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/features/home/home_screen.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';

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
                          ? AppColors.textGrey.withValues(alpha: 0.5)
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
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
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
