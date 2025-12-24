import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:hustlecoin/utils/localization.dart';

class LevelBenefitsDialog extends ConsumerWidget {
  const LevelBenefitsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.all(20.s),
      child: Container(
        // Outer Container with Angola Yellow Border
        padding: EdgeInsets.all(6.s), // Space between borders
        decoration: BoxDecoration(
          color: AppColors.uiDarkBg, // Themed dark background
          border: Border.all(
            color: AppColors.angolaYellow, // Gold border
            width: 4.s,
          ),
          borderRadius: BorderRadius.zero, // Boxy look
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 0,
              offset: Offset(8.s, 8.s), // Hard shadow
            ),
          ],
        ),
        child: Container(
          // Inner Border Container
          padding: EdgeInsets.all(24.s),
          decoration: BoxDecoration(
            color: AppColors.uiDarkBg,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1), // Subtle inner border
              width: 2.s,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                ref.t(LocalizationKeys.levelBenefits),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 24.f,
                  fontWeight: FontWeight.w900,
                  color: AppColors.angolaYellow, // Gold text
                  letterSpacing: 2,
                ),
              ),
              Divider(
                color: AppColors.angolaYellow.withValues(alpha: 0.3),
                thickness: 2.s,
                height: 32.s,
              ),

              // Bullet Points
              _buildBulletPoint(
                ref.t(LocalizationKeys.multiplierTitle),
                ref.t(LocalizationKeys.multiplierDesc),
              ),
              SizedBox(height: 16.s),
              _buildBulletPoint(
                ref.t(LocalizationKeys.landTitle),
                ref.t(LocalizationKeys.landDesc),
              ),
              SizedBox(height: 16.s),
              _buildBulletPoint(
                ref.t(LocalizationKeys.legacyTitle),
                ref.t(LocalizationKeys.legacyDesc),
              ),

              SizedBox(height: 32.s),

              // Close Button
              PressableScaleWidget(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.s),
                  decoration: BoxDecoration(
                    color: AppColors.angolaRed, // Themed Red button
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.3),
                      width: 2.s,
                    ),
                  ),
                  child: Text(
                    ref.t(LocalizationKeys.closeDialog),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16.f,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "> ",
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 16.f,
            fontWeight: FontWeight.bold,
            color: AppColors.angolaYellow,
          ),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "$title: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.angolaYellow,
                  ),
                ),
                TextSpan(text: desc),
              ],
            ),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 16.f,
              color: AppColors.textLight, // Lighter text for better contrast
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
