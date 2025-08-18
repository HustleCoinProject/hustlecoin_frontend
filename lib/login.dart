import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/state/all_states.dart';
import 'app_colors.dart';
import 'signup.dart';
import 'home_screen.dart';

// --- Reusable Helper Widgets ---

// High-performance "smoky glass" container without blur
class _GlassEffectContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const _GlassEffectContainer({
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: borderRadius,
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

// --- Main Login Screen Widget ---

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Example: Add controllers for your text fields
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    // Listen for the user state to change to navigate upon successful login
    ref.listen<AsyncValue<User?>>(userControllerProvider, (previous, next) {
      // Check if the new state has a user object and the old one didn't
      if (next is AsyncData && next.value != null) {
        // Navigate to the HomeScreen and remove all previous routes (like LoginScreen)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false, // This predicate removes all routes below
        );
      }
    });

    // Listen for loading/error states to give feedback
    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error.toString())));
      }
    });

    // Use a random image for the login screen background
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
        backgroundImages[DateTime.now().microsecond % backgroundImages.length];

    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: 380,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title and Subtitle
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Log in to continue your hustle.',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                    ),
                    const SizedBox(height: 30),

                    // Input Fields
                    _buildInputField(
                      icon: FontAwesomeIcons.user,
                      hintText: 'Email or Username',
                      controller: usernameController,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      icon: FontAwesomeIcons.lock,
                      hintText: 'Password',
                      controller: passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 5),

                    // Forgot Password Link
                    _buildForgotPasswordLink(),
                    const SizedBox(height: 20),

                    // Login Button
                    _buildActionButton(
                      text: 'Log In',
                      onTap: () async {
                        /*Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );*/
                        // Call the login method from the provider
                        await ref
                            .read(authControllerProvider.notifier)
                            .login(
                              usernameController.text,
                              passwordController.text,
                            );
                        print(
                          "Fetching user with token: ${ref.read(authControllerProvider).value}",
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // Sign Up Link
                    _buildSignUpLink(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper methods for building UI components ---

  Widget _buildInputField({
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    required TextEditingController? controller,
  }) {
    return _GlassEffectContainer(
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: AppColors.textLight, fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textGrey),
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 18),
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            // Handle forgot password logic
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(color: AppColors.textGrey, fontSize: 14),
          ),
        ),
      ],
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

  Widget _buildSignUpLink(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        children: [
          const TextSpan(text: "Don't have an account? "),
          TextSpan(
            text: 'Sign Up',
            style: const TextStyle(
              color: AppColors.angolaYellow,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
              },
          ),
        ],
      ),
    );
  }
}
