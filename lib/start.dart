import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'app_colors.dart';
import 'login.dart';

// --- Main Start Screen Widget ---

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen>
    with TickerProviderStateMixin {
  // Controllers for the animations
  late final AnimationController _titleController;
  late final AnimationController _glowController;

  late final Animation<double> _titleAnimation;

  // Timer and state for the background image slideshow
  Timer? _backgroundTimer;
  int _currentSlideIndex = 0;
  final List<String> _slides = [
    'assets/images/Cart Pusher.png',
    'assets/images/Taxi Driver.png',
    'assets/images/Manager.png',
    'assets/images/Hustle Legend.png',
  ];

  @override
  void initState() {
    super.initState();

    // Title "breathing" animation controller (pulses in and out)
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..repeat(reverse: true);

    _titleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );

    // Button glow animation controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    // Start the background slideshow timer
    _backgroundTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      setState(() {
        _currentSlideIndex = (_currentSlideIndex + 1) % _slides.length;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _glowController.dispose();
    _backgroundTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.angolaBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [_buildBackgroundSlider(), _buildContentOverlay()],
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildBackgroundSlider() {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 2),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Container(
        // The key is essential for AnimatedSwitcher to detect a change
        key: ValueKey<int>(_currentSlideIndex),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_slides[_currentSlideIndex]),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildContentOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            const Color(0xFF101010).withOpacity(0.3),
            const Color(0xFF101010).withOpacity(0.95),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              ScaleTransition(
                scale: _titleAnimation,
                child: Text(
                  ref.t(LocalizationKeys.welcomeToHustleCoin),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 50, // Adjusted for better fit on various screens
                    fontWeight: FontWeight.w800,
                    color: AppColors.textLight,
                    height: 1.1,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black87,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                ref.t(LocalizationKeys.earnByHustlingDaily),
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFFCCCCCC),
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black54,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              _buildStartButton(),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    // A custom Tween for the glow effect
    final glowTween = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 50),
    ]);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [AppColors.angolaYellow, AppColors.angolaRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.angolaYellow.withOpacity(0.7),
                  blurRadius: 35,
                  spreadRadius: glowTween.evaluate(_glowController),
                ),
                BoxShadow(
                  color: AppColors.angolaRed.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Text(
          ref.t(LocalizationKeys.startMyHustle),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
