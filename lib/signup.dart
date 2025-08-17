import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'app_colors.dart'; // Assuming you have this file from the previous step

// --- Reusable Widgets (can be moved to their own files later) ---

// High-performance "smoky glass" container without blur
class _GlassEffectContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;

  const _GlassEffectContainer({
    required this.child,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: borderRadius ?? BorderRadius.zero,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }
}

// Lightweight press feedback widget
class PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const PressableWidget({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.97,
  });

  @override
  State<PressableWidget> createState() => _PressableWidgetState();
}

class _PressableWidgetState extends State<PressableWidget> {
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

// --- Main Sign Up Screen Widget ---

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controller for the main 2-step PageView
  late final PageController _stepController;
  // Controller for the hustle carousel PageView
  late final PageController _hustleController;

  String _selectedLang = 'EN';
  int _selectedHustleIndex = 0;

  final List<Map<String, String>> hustles = [
    {'name': 'Taxi Driver', 'image': 'assets/images/Taxi Driver.png'},
    {'name': 'Street Vendor', 'image': 'assets/images/Street Vendor.png'},
    {'name': 'Delivery Rider', 'image': 'assets/images/Delivery Rider.png'},
  ];

  @override
  void initState() {
    super.initState();
    _stepController = PageController();
    _hustleController = PageController(viewportFraction: 0.8)
      ..addListener(() {
        setState(() {
          // Update the index when the page settles
          if (_hustleController.page!.round() != _selectedHustleIndex) {
            _selectedHustleIndex = _hustleController.page!.round();
          }
        });
      });
  }

  @override
  void dispose() {
    _stepController.dispose();
    _hustleController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _stepController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Taxi Driver.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                const Color(0xFF101010).withOpacity(0.4),
                const Color(0xFF101010).withOpacity(0.9),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: PageView(
                  controller: _stepController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [_buildStep1(), _buildStep2()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Step 1: User Details ---
  Widget _buildStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Create Account',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 30),
        _buildInputField(icon: FontAwesomeIcons.user, hintText: 'Username'),
        const SizedBox(height: 20),
        _buildInputField(icon: FontAwesomeIcons.envelope, hintText: 'Email'),
        const SizedBox(height: 20),
        _buildInputField(
          icon: FontAwesomeIcons.lock,
          hintText: 'Password',
          obscureText: true,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          icon: FontAwesomeIcons.checkCircle,
          hintText: 'Confirm Password',
          obscureText: true,
        ),
        const SizedBox(height: 20),
        _buildLanguageSelector(),
        const SizedBox(height: 20),
        _buildActionButton(text: 'Next', onTap: () => _goToStep(1)),
      ],
    );
  }

  // --- Step 2: Choose Hustle ---
  Widget _buildStep2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Choose Your Hustle',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 30),
        SizedBox(
          height: 350, // Give the carousel a fixed height
          child: PageView.builder(
            controller: _hustleController,
            itemCount: hustles.length,
            itemBuilder: (context, index) {
              return _buildHustleCard(index);
            },
          ),
        ),
        const SizedBox(height: 30),
        _buildActionButton(
          text: 'Create Account',
          onTap: () {
            // Final account creation logic goes here
          },
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _goToStep(0),
          child: const Text(
            'Go Back',
            style: TextStyle(color: AppColors.textGrey, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // --- Reusable UI Component Builders ---

  Widget _buildInputField({
    required IconData icon,
    required String hintText,
    bool obscureText = false,
  }) {
    return _GlassEffectContainer(
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        obscureText: obscureText,
        style: const TextStyle(color: AppColors.textLight, fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textGrey),
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 18),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return _GlassEffectContainer(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(5),
      child: Row(children: [_buildLangOption('EN'), _buildLangOption('PT')]),
    );
  }

  Widget _buildLangOption(String lang) {
    bool isActive = _selectedLang == lang;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedLang = lang),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.angolaYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            lang,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.angolaBlack : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return PressableWidget(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [AppColors.angolaYellow, AppColors.angolaRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildHustleCard(int index) {
    bool isSelected = index == _selectedHustleIndex;
    final hustle = hustles[index];

    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: isSelected ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.angolaYellow : Colors.transparent,
              width: 3,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.glowYellow,
                      blurRadius: 25,
                      spreadRadius: -5,
                    ),
                  ]
                : [],
          ),
          child: _GlassEffectContainer(
            borderRadius: BorderRadius.circular(
              17,
            ), // Slightly smaller to show border
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Uri.parse(hustle['image']!).isAbsolute
                        ? Image.network(
                            hustle['image']!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Image.asset(
                            hustle['image']!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  hustle['name']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
