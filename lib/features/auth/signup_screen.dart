import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/repositories/api_repository.dart';
import 'package:hustlecoin/features/auth/login_screen.dart';
import 'package:hustlecoin/features/home/home_screen.dart';
import 'package:hustlecoin/providers/auth_provider.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/theme/app_colors.dart';

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
        border: Border.all(color: AppColors.glassBorder, width: 1.s),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10.s),
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
        if (widget.onTap != null) {
          // Play click sound before calling onTap
          SoundService().playClick();
          widget.onTap!.call();
        }
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

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  // Controller for the main 2-step PageView
  late final PageController _stepController;
  // Controller for the hustle carousel PageView
  late final PageController _hustleController;

  // Form controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selectedLang = 'EN';
  int _selectedHustleIndex = 0;
  List<Map<String, String>> _level1Hustles = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _stepController = PageController();
    _hustleController = PageController(viewportFraction: 0.8)
      ..addListener(() {
        setState(() {
          // Update the index when the page settles
          if (_hustleController.page != null &&
              _hustleController.page!.round() != _selectedHustleIndex) {
            _selectedHustleIndex = _hustleController.page!.round();
          }
        });
      });

    // Fetch level 1 hustles when the widget initializes
    _fetchLevel1Hustles();
  }

  Future<void> _fetchLevel1Hustles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiRepo = ApiRepository(); // Create instance without auth token
      final allHustles = await apiRepo.getAllHustles();

      // Extract level 1 hustles (now returns Map<String, String>)
      final level1HustleMap = allHustles['1'] ?? <String, String>{};

      setState(() {
        _level1Hustles = level1HustleMap.entries
            .map(
              (entry) => {
                'key': entry.key, // English name (for API calls)
                'name': entry.value, // Localized name (for display)
                'image':
                    'assets/images/${entry.key}.png', // Use key for image path
              },
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load available hustles: $e';
        _isLoading = false;
      });
    }
  }

  void _registerUser() {
    // Form validation
    if (_usernameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Username is required';
      });
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Email is required';
      });
      return;
    }

    // Basic email validation
    if (!_emailController.text.trim().contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Password is required';
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters long';
      });
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please confirm your password';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (_level1Hustles.isEmpty) {
      setState(() {
        _errorMessage = 'No hustles available to select';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Get the selected hustle key (English name for API)
    final selectedHustleKey = _level1Hustles[_selectedHustleIndex]['key'] ?? '';

    // Create an instance of ApiRepository
    final apiRepo = ApiRepository();

    // Use Future.delayed to avoid the "Future<void> Function()?" error with onTap
    Future.delayed(Duration.zero, () async {
      try {
        // Register the user using the hustle key
        await apiRepo.register(
          _emailController.text.trim(),
          _passwordController.text,
          _usernameController.text.trim(),
          selectedHustleKey, // Use the key (English name)
          _selectedLang.toLowerCase(),
        );

        // Update auth state - this will handle login and token storage
        await ref
            .read(authControllerProvider.notifier)
            .login(_usernameController.text.trim(), _passwordController.text);

        // Navigate to home screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } catch (e) {
        setState(() {
          // Extract more meaningful error message
          String errorMessage = e.toString();
          if (errorMessage.contains('Exception:')) {
            errorMessage = errorMessage.replaceFirst('Exception: ', '');
          }
          if (errorMessage.contains('Failed to register:')) {
            errorMessage = errorMessage.replaceFirst(
              'Failed to register: ',
              '',
            );
          }

          _errorMessage = errorMessage;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _stepController.dispose();
    _hustleController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    // Use a random image for the signup screen background
    final List<String> backgroundImages = [
      'Business Director.png',
      'Cart Pusher.png',
      'CEO.png',
      'Hustle Legend.png',
      'Lawyer.png',
      'Manager.png',
      'Minister.png',
      'Motorcycle Owner.png',
      'President.png',
      'Secretary.png',
      'Shopkeeper.png',
      'Small Farmer.png',
      'Store Owner.png',
      'Street Vendor.png',
    ];
    final String randomImage =
        backgroundImages[DateTime.now().millisecond % backgroundImages.length];

    return ResponsiveBuilder(
      builder: (context) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/$randomImage'),
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
                padding: ResponsiveUtils.pSymmetric(horizontal: 20.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    children: [
                      // Show error message if any
                      if (_errorMessage != null)
                        Container(
                          margin: EdgeInsets.only(bottom: 20.s),
                          padding: ResponsiveUtils.pSymmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.6),
                            ),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.f,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Main content
                      Expanded(
                        child: PageView(
                          controller: _stepController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [_buildStep1(), _buildStep2()],
                        ),
                      ),
                    ],
                  ),
                ), // Closing SizedBox
              ),
            ),
          ),
        ),
      ), // Closing ResponsiveBuilder
    );
  }

  // --- Step 1: User Details ---
  Widget _buildStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Create Account',
          style: TextStyle(fontSize: 28.f, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 30.s),
        _buildInputField(
          icon: FontAwesomeIcons.user,
          hintText: 'Username',
          controller: _usernameController,
        ),
        SizedBox(height: 20.s),
        _buildInputField(
          icon: FontAwesomeIcons.envelope,
          hintText: 'Email',
          controller: _emailController,
        ),
        SizedBox(height: 20.s),
        _buildInputField(
          icon: FontAwesomeIcons.lock,
          hintText: 'Password',
          obscureText: true,
          controller: _passwordController,
        ),
        SizedBox(height: 20.s),
        _buildInputField(
          icon: FontAwesomeIcons.checkCircle,
          hintText: 'Confirm Password',
          obscureText: true,
          controller: _confirmPasswordController,
        ),
        SizedBox(height: 20.s),
        _buildLanguageSelector(),
        SizedBox(height: 20.s),
        _buildActionButton(text: 'Next', onTap: () => _goToStep(1)),
        SizedBox(height: 20.s),
        // Already have account link
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 14.f,
              fontFamily: 'Poppins',
            ),
            children: [
              const TextSpan(text: "Already have an account? "),
              TextSpan(
                text: 'Login',
                style: TextStyle(
                  color: AppColors.angolaYellow,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.f,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Step 2: Choose Hustle ---
  Widget _buildStep2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Choose Your Hustle',
          style: TextStyle(fontSize: 28.f, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 30.s),
        if (_isLoading)
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.angolaYellow),
          )
        else if (_level1Hustles.isEmpty)
          Text(
            'No hustles available. Please try again later.',
            style: TextStyle(color: AppColors.textGrey, fontSize: 16.f),
            textAlign: TextAlign.center,
          )
        else
          SizedBox(
            height: 350.s, // Give the carousel a fixed height
            child: PageView.builder(
              controller: _hustleController,
              itemCount: _level1Hustles.length,
              itemBuilder: (context, index) {
                return _buildHustleCard(index);
              },
            ),
          ),
        const SizedBox(height: 30),
        _buildActionButton(
          text: 'Create Account',
          onTap: _isLoading ? null : () => _registerUser(),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _isLoading ? null : () => _goToStep(0),
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
    TextEditingController? controller,
  }) {
    return _GlassEffectContainer(
      borderRadius: BorderRadius.circular(12.r),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: AppColors.textLight, fontSize: 16.f),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 16.f),
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 18.s),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return _GlassEffectContainer(
      borderRadius: BorderRadius.circular(12.r),
      padding: EdgeInsets.all(5.s),
      child: Row(children: [_buildLangOption('EN'), _buildLangOption('PT')]),
    );
  }

  Widget _buildLangOption(String lang) {
    bool isActive = _selectedLang == lang;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedLang = lang),
        child: Container(
          padding: ResponsiveUtils.pSymmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.angolaYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
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

  Widget _buildActionButton({required String text, VoidCallback? onTap}) {
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
    final hustle = _level1Hustles[index];

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
