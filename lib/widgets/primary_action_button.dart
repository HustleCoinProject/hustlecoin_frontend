import 'package:flutter/material.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'pressable_scale_widget.dart';

class PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final EdgeInsetsGeometry? padding; // optional padding override

  const PrimaryActionButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScaleWidget(
      onTap: isLoading ? null : onTap,
      child: Container(
        // width: double.infinity, // <-- REMOVE THIS LINE
        padding:
            padding ??
            ResponsiveUtils.pSymmetric(vertical: 15), // Use default or override
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            colors: (onTap == null || isLoading)
                ? [
                    AppColors.textGrey,
                    AppColors.textGrey.withValues(alpha: 0.7),
                  ]
                : [AppColors.angolaYellow, AppColors.angolaRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20.s,
                  height: 20.s,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.f,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
