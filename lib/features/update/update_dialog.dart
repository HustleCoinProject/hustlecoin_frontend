import 'package:flutter/material.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
                'UPDATE AVAILABLE',
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

              // Content
              Text(
                'A new version of Hustle Coin is available. Update now for the latest features!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16.f,
                  color: AppColors.textLight,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 32.s),

              // OK Button
              PressableScaleWidget(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.s),
                  decoration: BoxDecoration(
                    color: AppColors.angolaYellow, // Yellow for positive action
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.3),
                      width: 2.s,
                    ),
                  ),
                  child: Text(
                    'OK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16.f,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Black text on yellow button
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
}
