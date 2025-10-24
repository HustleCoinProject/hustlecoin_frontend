import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';

class BottomNavBar extends ConsumerWidget {
  final int activeIndex;
  final ValueChanged<int> onNavItemTapped;

  const BottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onNavItemTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      borderRadius: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        child: Padding(
          padding: ResponsiveUtils.pLTRB(0, 8, 0, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: FontAwesomeIcons.house,
                label: ref.t(LocalizationKeys.home),
                index: 0,
                ref: ref,
              ),
              _buildNavItem(
                icon: FontAwesomeIcons.chartLine,
                label: ref.t(LocalizationKeys.leaderboard),
                index: 1,
                ref: ref,
              ),
              _buildNavItem(
                icon: FontAwesomeIcons.userCircle,
                label: ref.t(LocalizationKeys.profile),
                index: 2,
                ref: ref,
              ),
              _buildNavItem(
                icon: FontAwesomeIcons.cog,
                label: ref.t(LocalizationKeys.settings),
                index: 3,
                ref: ref,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required WidgetRef ref,
  }) {
    final bool isActive = activeIndex == index;
    final color = isActive ? AppColors.angolaYellow : AppColors.textGrey;
    final shadows = isActive
        ? [Shadow(color: AppColors.glowYellow, blurRadius: 10)]
        : <Shadow>[];

    return Expanded(
      child: InkWell(
        onTap: () {
          SoundService().playClick();
          onNavItemTapped(index);
        },
        customBorder: const CircleBorder(),
        splashColor: AppColors.angolaYellow.withValues(alpha: 0.15),
        highlightColor: AppColors.angolaYellow.withValues(alpha: 0.1),
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
