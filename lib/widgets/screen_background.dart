import 'package:flutter/material.dart';
import 'package:hustlecoin/widgets/particle_overlay.dart';

class ScreenBackground extends StatelessWidget {
  final String imagePath;
  final Widget child;

  const ScreenBackground({
    super.key,
    required this.imagePath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  const Color(0xFF101010).withValues(alpha: 0.4),
                  const Color(0xFF101010).withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          // Particle Effect
          const IgnorePointer(
            child: ParticleOverlay(
              numberOfParticles: 40,
              color: Color(0xFFFFFFFF),
            ),
          ),
          // Content
          child,
        ],
      ),
    );
  }
}
