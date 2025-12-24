import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/providers/user_provider.dart';

import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:hustlecoin/features/home/widgets/level_benefits_dialog.dart';

class GameAvatarWidget extends ConsumerWidget {
  const GameAvatarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch user level/stats if needed for customization
    final userState = ref.watch(userControllerProvider);
    final user = userState.value;
    final level = user?.level ?? 1;

    return PressableScaleWidget(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const LevelBenefitsDialog(),
        );
      },
      child: SizedBox(
        width: 68.s,
        height: 68.s,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Outer Glow
            Container(
              width: 58.s,
              height: 58.s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.angolaYellow.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // Hexagon Background
            Container(
              width: 58.s,
              height: 58.s,
              decoration: ShapeDecoration(
                shape: StarBorder(
                  points: 6,
                  innerRadiusRatio: 0.88,
                  pointRounding: 0.1,
                  side: BorderSide(color: AppColors.angolaYellow, width: 2),
                ),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shadows: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  FontAwesomeIcons.solidUser,
                  size: 26.s,
                  // Use a gradient shader for the icon if possible, or just a solid color
                  color: AppColors.textLight,
                ),
              ),
            ),

            // Level Badge (Bottom Center)
            Positioned(
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.s, vertical: 2.s),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.angolaRed, AppColors.orange],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.textLight.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'LVL $level',
                  style: TextStyle(
                    fontSize: 10.f,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Optional: Notification Indicator if needed here
            // (But notification is separate in TopBar, so skipping)
          ],
        ),
      ),
    );
  }
}
