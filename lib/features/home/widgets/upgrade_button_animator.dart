import 'package:flutter/material.dart';

// Animated upgrade button wrapper
class UpgradeButtonAnimator extends StatefulWidget {
  final Widget child;
  final bool isEnabled;

  const UpgradeButtonAnimator({
    super.key,
    required this.child,
    required this.isEnabled,
  });

  @override
  State<UpgradeButtonAnimator> createState() => _UpgradeButtonAnimatorState();
}

class _UpgradeButtonAnimatorState extends State<UpgradeButtonAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start animation if it's already enabled on first build
    if (widget.isEnabled) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(UpgradeButtonAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start or stop the animation based on the isEnabled state change
    if (widget.isEnabled && !oldWidget.isEnabled) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isEnabled && oldWidget.isEnabled) {
      _animationController.stop();
      _animationController.value = 0.0; // Reset animation
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If not enabled, just return the plain child without animations.
    if (!widget.isEnabled) {
      return widget.child;
    }

    // Otherwise, apply the scaling animation.
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: widget.child,
    );
  }
}
