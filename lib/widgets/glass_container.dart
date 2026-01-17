import 'package:flutter/material.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';

/// A high-performance, responsive "smoky glass" container.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxShape shape;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 12.0,
    this.padding,
    this.shape = BoxShape.rectangle,
    this.border,
    this.boxShadow,
    this.color,
    this.gradient,
    this.borderColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.glassBg,
        gradient: gradient,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius.r)
            : null,
        border:
            border ??
            Border.all(color: borderColor ?? AppColors.glassBorder, width: 1),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10.s,
              ),
            ],
      ),
      child: child,
    );
  }
}
