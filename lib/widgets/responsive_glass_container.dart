// lib/widgets/responsive_glass_container.dart

import 'package:flutter/material.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';

/// High-performance responsive "smoky glass" container without blur
class ResponsiveGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isCircle;

  const ResponsiveGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 0,
    this.padding,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius.r),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }
}

/// Responsive pressable widget for better touch feedback
class ResponsivePressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final double borderRadius;

  const ResponsivePressableWidget({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.97,
    this.borderRadius = 0,
  });

  @override
  State<ResponsivePressableWidget> createState() =>
      _ResponsivePressableWidgetState();
}

class _ResponsivePressableWidgetState extends State<ResponsivePressableWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleFactor : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
