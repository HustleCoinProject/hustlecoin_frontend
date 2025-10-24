import 'package:flutter/material.dart';
import 'package:hustlecoin/services/sound_service.dart';

/// A widget that provides a subtle scaling animation on press and plays a sound effect.
class PressableScaleWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final SoundType? soundType; // Optional sound override

  const PressableScaleWidget({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.97,
    this.soundType, // Default click sound will be used if null
  });

  @override
  State<PressableScaleWidget> createState() => _PressableScaleWidgetState();
}

class _PressableScaleWidgetState extends State<PressableScaleWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) setState(() => _isPressed = true);
        SoundService().playSound(widget.soundType ?? SoundType.click);
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = false);
          widget.onTap!.call();
        }
      },
      onTapCancel: () {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleFactor : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
