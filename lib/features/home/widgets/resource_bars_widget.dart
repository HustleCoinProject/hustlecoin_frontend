import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/providers/time_provider.dart';

class ResourceBarsWidget extends ConsumerStatefulWidget {
  const ResourceBarsWidget({super.key});

  @override
  ConsumerState<ResourceBarsWidget> createState() => _ResourceBarsWidgetState();
}

class _ResourceBarsWidgetState extends ConsumerState<ResourceBarsWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update the UI every second to smoothly animate energy passive regen
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Just trigger rebuild, time comes from provider
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(userControllerProvider);
    final currentServerTime = ref
        .watch(serverTimeProvider.notifier)
        .currentServerTime;

    return userAsyncValue.when(
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        // --- Energy Calculation ---
        double exactEnergy = user.energy.toDouble();
        if (user.energy < user.maxEnergy) {
          final secondsPassed = currentServerTime
              .difference(user.energyUpdatedAt.toUtc())
              .inSeconds;
          // Regeneration rate: 1 energy per minute (60 seconds)
          if (secondsPassed > 0) {
            exactEnergy = user.energy + (secondsPassed / 60.0);
          }
        }
        exactEnergy = exactEnergy.clamp(0.0, user.maxEnergy.toDouble());
        int displayEnergy = exactEnergy.floor();

        // --- Activity Calculation ---
        // Activity has daily decay handled mostly on the backend upon task execution/fetching,
        // but we can locally determine if decay should have happened.
        // For simplicity right now, we just display the backend value securely.
        double exactActivity = user.activity.toDouble();
        if (user.activity > 0) {
          final daysPassed = currentServerTime
              .difference(user.activityUpdatedAt.toUtc())
              .inDays;
          if (daysPassed > 0) {
            exactActivity = (user.activity - (daysPassed * 2)).toDouble();
          }
        }
        exactActivity = exactActivity.clamp(0.0, user.maxActivity.toDouble());
        int displayActivity = exactActivity.floor();

        return Padding(
          padding: ResponsiveUtils.pSymmetric(horizontal: 15, vertical: 0),
          child: Row(
            children: [
              // Energy Bar (Left)
              Expanded(
                child: _buildResourceGlass(
                  icon: FontAwesomeIcons.boltLightning,
                  iconColor: Colors.blueAccent,
                  label: 'Energy',
                  progress:
                      exactEnergy / (user.maxEnergy > 0 ? user.maxEnergy : 1),
                  textLeft: '$displayEnergy',
                  textRight: '${user.maxEnergy}',
                  progressColor: Colors.blueAccent,
                ),
              ),

              SizedBox(width: 10.w),

              // Activity Bar (Right)
              Expanded(
                child: _buildResourceGlass(
                  icon: FontAwesomeIcons.fire,
                  iconColor: Colors.orangeAccent,
                  label: 'Activity',
                  progress:
                      exactActivity /
                      (user.maxActivity > 0 ? user.maxActivity : 1),
                  textLeft: '$displayActivity',
                  textRight: '${user.maxActivity}',
                  progressColor: Colors.orangeAccent,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildResourceGlass({
    required IconData icon,
    required Color iconColor,
    required String label,
    required double progress,
    required String textLeft,
    required String textRight,
    required Color progressColor,
  }) {
    return GlassContainer(
      padding: ResponsiveUtils.pSymmetric(horizontal: 10, vertical: 8),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, size: 14.s, color: iconColor),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12.f,
                  fontWeight: FontWeight.w700,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Stack(
            children: [
              Container(
                height: 8.h,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(4.r),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                textLeft,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 10.f,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                textRight,
                style: TextStyle(color: AppColors.textGrey, fontSize: 10.f),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
