import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/mission.dart';
import 'package:hustlecoin/features/missions/mission_detail_screen.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';

class MissionCard extends ConsumerWidget {
  final Mission mission;

  const MissionCard({super.key, required this.mission});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PressableScaleWidget(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MissionDetailScreen(mission: mission),
          ),
        );
      },
      child: GlassContainer(
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
        child: Row(
          children: [
            // Left: Icon/Image
            Container(
              width: 45.s, // Smaller icon container
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
                  size: 20.s, // Smaller icon
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
                    mission.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.f, // Slightly smaller title
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
                          vertical: 2.h, // Reduced vertical padding
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(
                            mission.difficulty,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          mission.difficulty.toUpperCase(),
                          style: TextStyle(
                            color: _getDifficultyColor(mission.difficulty),
                            fontSize: 9.f, // Slightly smaller font
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.s),
                      // Reward Capsule (New)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.angolaYellow.withValues(alpha: 0.1),
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
                              '+${mission.rewardAmount}',
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

            // Right: Arrow Button
            Container(
              padding: EdgeInsets.all(8.s),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 16.s,
              ),
            ),
          ],
        ),
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
