import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hustlecoin/data/models/mission.dart';
import 'package:hustlecoin/providers/mission_provider.dart';
import 'package:hustlecoin/providers/time_provider.dart';
import 'package:hustlecoin/services/admob_service.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';

class MissionCard extends ConsumerStatefulWidget {
  final Mission mission;

  const MissionCard({super.key, required this.mission});

  @override
  ConsumerState<MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends ConsumerState<MissionCard> {
  Timer? _timer;
  double _progress = 0.0;
  bool _isSpeedingUp = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateProgress();
      }
    });
  }

  void _updateProgress() {
    final state = ref.read(activeMissionProvider);
    if (!state.isMissionActive ||
        state.missionStartTime == null ||
        state.currentMission?.id != widget.mission.id) {
      setState(() => _progress = 0.0);
      return;
    }

    final serverTime = ref.read(serverTimeProvider.notifier).currentServerTime;
    final elapsed = serverTime.difference(state.missionStartTime!).inSeconds;
    final total = widget.mission.durationSeconds;

    double newProgress = elapsed / total;
    if (newProgress >= 1.0) {
      newProgress = 1.0;
      // Auto-complete if it reaches 100% and isn't already completing
      if (!state.isLoading && !state.isMissionCompleted) {
        ref.read(activeMissionProvider.notifier).completeMissionOnBackend();
      }
    }

    setState(() {
      _progress = newProgress;
    });
  }

  Future<void> _handleSpeedup() async {
    setState(() => _isSpeedingUp = true);

    final adMobService = AdMobService();
    if (!adMobService.isAdLoaded) {
      await adMobService.loadRewardedAd();
    }
    if (!mounted) {
      setState(() => _isSpeedingUp = false);
      return;
    }

    if (!adMobService.isAdLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad not ready yet. Please try again.'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() => _isSpeedingUp = false);
      return;
    }

    final adWatched = await adMobService.showRewardedAd();
    if (adWatched && mounted) {
      // Reduce time by 25% of total duration
      final secondsToReduce = (widget.mission.durationSeconds * 0.25).round();
      await ref
          .read(activeMissionProvider.notifier)
          .speedupMission(secondsToReduce);
      _updateProgress();
    }

    if (mounted) {
      setState(() => _isSpeedingUp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final missionState = ref.watch(activeMissionProvider);
    final isActive =
        missionState.isMissionActive &&
        missionState.currentMission?.id == widget.mission.id;
    final isCompleted =
        missionState.isMissionCompleted &&
        missionState.currentMission?.id == widget.mission.id;

    // Call update progress immediately on build to ensure it's fresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateProgress();
    });

    return GlassContainer(
      margin: ResponsiveUtils.pSymmetric(horizontal: 0, vertical: 0),
      padding: ResponsiveUtils.p(15),
      borderRadius: 20,
      gradient: LinearGradient(
        colors: [
          AppColors.angolaBlack.withValues(alpha: 0.6),
          AppColors.angolaBlack.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: AppColors.angolaYellow.withValues(alpha: 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Left: Icon/Image
              Container(
                width: 45.s,
                height: 45.s,
                decoration: BoxDecoration(
                  color: AppColors.angolaYellow.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.angolaYellow.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    FontAwesomeIcons.rocket,
                    color: AppColors.angolaYellow,
                    size: 20.s,
                  ),
                ),
              ),
              SizedBox(width: 15.s),

              // Center: Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.mission.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.f,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.s),
                    Row(
                      children: [
                        // Difficulty Capsule
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(
                              widget.mission.difficulty,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.mission.difficulty.toUpperCase(),
                            style: TextStyle(
                              color: _getDifficultyColor(
                                widget.mission.difficulty,
                              ),
                              fontSize: 9.f,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.s),
                        // Reward Capsule
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.angolaYellow.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.angolaYellow.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FontAwesomeIcons.coins,
                                color: AppColors.angolaYellow,
                                size: 9.s,
                              ),
                              SizedBox(width: 4.s),
                              Text(
                                '+${widget.mission.rewardAmount}',
                                style: TextStyle(
                                  color: AppColors.angolaYellow,
                                  fontSize: 10.f,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (isActive) ...[
            SizedBox(height: 15.s),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 12.s,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.angolaYellow,
                ),
              ),
            ),
            SizedBox(height: 10.s),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(_progress * 100).toInt()}% Completed',
                  style: TextStyle(color: Colors.white70, fontSize: 12.f),
                ),
                if (_progress < 1.0)
                  PressableScaleWidget(
                    onTap: _isSpeedingUp ? null : _handleSpeedup,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.orange.withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSpeedingUp)
                            SizedBox(
                              width: 10.s,
                              height: 10.s,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          else
                            Icon(
                              FontAwesomeIcons.forwardFast,
                              color: Colors.white,
                              size: 10.s,
                            ),
                          SizedBox(width: 6.s),
                          Text(
                            'Speedup',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.f,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ] else if (isCompleted) ...[
            SizedBox(height: 15.s),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(activeMissionProvider.notifier).fetchActiveMission();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'MISSION COMPLETED! NEXT ➔',
                  style: TextStyle(
                    fontSize: 14.f,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(height: 15.s),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(activeMissionProvider.notifier).startMission();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.angolaYellow,
                  foregroundColor: AppColors.angolaBlack,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'START TASK',
                  style: TextStyle(
                    fontSize: 14.f,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.greenAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'hard':
        return Colors.redAccent;
      default:
        return AppColors.angolaYellow;
    }
  }
}
