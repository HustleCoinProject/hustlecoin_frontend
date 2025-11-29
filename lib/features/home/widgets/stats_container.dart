// lib/widgets/stats_container.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/data/models/user.dart';
import 'package:hustlecoin/features/level_up/select_hustle_screen.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/providers/user_specific_data_provider.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:hustlecoin/providers/foundational_providers.dart';
import './upgrade_button_animator.dart';

class StatsContainer extends ConsumerWidget {
  final User user;
  const StatsContainer({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelStatusAsync = ref.watch(levelStatusProvider);

    return levelStatusAsync.when(
      loading: () => levelStatusAsync.hasValue
          ? _buildStatsContent(context, ref, user, levelStatusAsync.value!)
          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (err, stack) => levelStatusAsync.hasValue
          ? _buildStatsContent(context, ref, user, levelStatusAsync.value!)
          : const Center(child: Text("Error")),
      data: (status) => status == null
          ? const Center(child: Text("Could not load stats."))
          : _buildStatsContent(context, ref, user, status),
    );
  }

  Widget _buildStatsContent(
    BuildContext context,
    WidgetRef ref,
    User user,
    dynamic status,
  ) {
    const textShadow = [
      Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(1, 1)),
    ];
    final progress = status.hcEarnedInLevelProgress.toDouble();
    final required = status.hcEarnedInLevelRequired.toDouble();
    final progressValue = required > 0
        ? (progress / required).clamp(0.0, 1.0)
        : 0.0;

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
              SizedBox(height: 4.s),
              Text(
                '🏆 Rank Points: ${user.rankPoints}',
                style: TextStyle(
                  fontSize: 12.f,
                  color: AppColors.angolaYellow,
                  fontWeight: FontWeight.w600,
                  shadows: textShadow,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 15.s),
        Expanded(
          child: Column(
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
                        color: Colors.black.withValues(alpha: 0.4),
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
                              : AppColors.orange.withValues(alpha: 0.3),
                          blurRadius: status.isEligibleForUpgrade ? 15 : 10,
                          spreadRadius: status.isEligibleForUpgrade ? 0 : -2,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: UpgradeButtonAnimator(
                      isEnabled: status.isEligibleForUpgrade,
                      child: PressableScaleWidget(
                        onTap: status.isEligibleForUpgrade
                            ? () async {
                                try {
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                                  final apiRepo = ref.read(
                                    apiRepositoryProvider,
                                  );
                                  final result = await apiRepo.levelUpgrade();
                                  final int newLevel = result['new_level'];
                                  final dynamic newHustleObj =
                                      result['new_hustle'];
                                  final String newHustleKey =
                                      HustleUtils.getCurrentHustleKey(
                                        newHustleObj,
                                      );
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
                                  ref.invalidate(userControllerProvider);
                                  ref.invalidate(levelStatusProvider);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
          ),
        ),
      ],
    );
  }
}
