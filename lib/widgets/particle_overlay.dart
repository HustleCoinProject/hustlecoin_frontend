import 'dart:math';
import 'package:flutter/material.dart';

class ParticleOverlay extends StatefulWidget {
  final Color color;
  final int numberOfParticles;

  const ParticleOverlay({
    super.key,
    this.color = const Color(0xFFFFFFFF),
    this.numberOfParticles = 30, // Reduced count for subtlety
  });

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 10,
      ), // Long duration for continuous loop
    )..repeat(); // Loop indefinitely

    _particles = List.generate(
      widget.numberOfParticles,
      (index) => _createParticle(fullScreen: true),
    );
  }

  Particle _createParticle({bool fullScreen = false}) {
    return Particle(
      x: _random.nextDouble(),
      // If fullScreen is true, distribute randomly across height,
      // otherwise start at bottom
      y: fullScreen ? _random.nextDouble() : 1.1,
      speed: 0.05 + _random.nextDouble() * 0.15, // Slow rising speed
      theta: _random.nextDouble() * 2 * pi,
      radius: 0.5 + _random.nextDouble() * 2.5, // Small particles
      opacity: 0.05 + _random.nextDouble() * 0.15, // Very faint
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Update particle positions
        for (var particle in _particles) {
          particle.y -= particle.speed * 0.01; // Move up
          particle.x += sin(particle.theta) * 0.002; // Gentle wobble
          particle.theta += 0.05;

          // Reset if goes off screen top
          if (particle.y < -0.1) {
            // Re-initialize particle at the bottom
            // We can reuse the object but copying values is cleaner simpler for now
            final newP = _createParticle();
            particle.x = newP.x;
            particle.y = newP.y;
            particle.speed = newP.speed;
            particle.theta = newP.theta;
            particle.radius = newP.radius;
            particle.opacity = newP.opacity;
          }
        }

        return CustomPaint(
          size: Size.infinite,
          painter: ParticlePainter(particles: _particles, color: widget.color),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double speed;
  double theta;
  double radius;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.theta,
    required this.radius,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;

  ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
