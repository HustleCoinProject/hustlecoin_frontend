import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';

class ResourceBarsWidget extends StatelessWidget {
  const ResourceBarsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    const int energyCurrent = 50;
    const int energyMax = 100;
    const int activityCurrent = 75;
    const int activityMax = 100;

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
              progress: energyCurrent / energyMax,
              textLeft: '$energyCurrent',
              textRight: '$energyMax',
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
              progress: activityCurrent / activityMax,
              textLeft: '$activityCurrent',
              textRight: '$activityMax',
              progressColor: Colors.orangeAccent,
            ),
          ),
        ],
      ),
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
