import 'package:flutter/material.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';

class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final String? label; // Alias for text
  final IconData? icon;
  final Color? color;
  final bool isLoading;
  final bool isPrimary;
  final bool isSecondary;

  const GlassButton({
    Key? key,
    required this.onPressed,
    this.text,
    this.label,
    this.icon,
    this.color,
    this.isLoading = false,
    this.isPrimary = false,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String buttonText = text ?? label ?? '';
    final Color baseColor =
        color ??
        (isPrimary
            ? AppColors.angolaRed
            : isSecondary
            ? AppColors.glassBg
            : AppColors.glassBg);

    return Container(
      decoration: BoxDecoration(
        color: baseColor.withOpacity(isPrimary ? 0.8 : 0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isPrimary
              ? AppColors.angolaRed.withOpacity(0.5)
              : AppColors.glassBorder.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 12.s),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20.s,
                      height: 20.s,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.s,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 18.s),
                          SizedBox(width: 8.s),
                        ],
                        Flexible(
                          child: Text(
                            buttonText,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.f,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
