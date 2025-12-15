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
  final VoidCallback? onGetPaidTapped;
  final GlobalKey? getPaidKey;
  final GlobalKey? profileNavKey;

  const BottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onNavItemTapped,
    this.onGetPaidTapped,
    this.getPaidKey,
    this.profileNavKey,
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
              _buildGetPaidButton(ref),
              _buildNavItem(
                icon: FontAwesomeIcons.userCircle,
                label: ref.t(LocalizationKeys.profile),
                index: 2,
                ref: ref,
                navKey: profileNavKey,
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
    GlobalKey? navKey,
  }) {
    final bool isActive = activeIndex == index;
    final color = isActive ? AppColors.angolaYellow : AppColors.textGrey;
    final shadows = isActive
        ? [Shadow(color: AppColors.glowYellow, blurRadius: 10)]
        : <Shadow>[];

    return Expanded(
      key: navKey,
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

  Widget _buildGetPaidButton(WidgetRef ref) {
    return Expanded(
      key: getPaidKey,
      child: InkWell(
        onTap: () {
          SoundService().playClick();
          onGetPaidTapped?.call();
        },
        customBorder: const CircleBorder(),
        splashColor: AppColors.angolaYellow.withValues(alpha: 0.15),
        highlightColor: AppColors.angolaYellow.withValues(alpha: 0.1),
        child: Container(
          padding: ResponsiveUtils.pSymmetric(vertical: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.1),
                blurRadius: 4,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.wallet,
                size: 22.s,
                color: AppColors.orange,
                shadows: [
                  Shadow(
                    color: AppColors.orange.withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
              SizedBox(height: 4.s),
              Text(
                ref.t(LocalizationKeys.getPaid).toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.f,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.orange,
                  shadows: [
                    Shadow(
                      color: AppColors.orange.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
