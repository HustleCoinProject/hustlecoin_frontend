import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/user.dart';
import 'package:hustlecoin/features/home/home_screen.dart';
import 'package:hustlecoin/providers/auth_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/widgets/primary_action_button.dart';
import 'signup_screen.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/screen_background.dart';

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
      'Business Director.jpg',
      'Cart Pusher.jpg',
      'CEO.jpg',
      'Hustle Legend.jpg',
      'Lawyer.jpg',
      'Manager.jpg',
      'Minister.jpg',
      'Motorcycle Owner.jpg',
      'President.jpg',
      'Secretary.jpg',
      'Shopkeeper.jpg',
      'Small Farmer.jpg',
      'Store Owner.jpg',
      'Street Vendor.jpg',
    ];
    final String randomImage =
        backgroundImages[DateTime.now().microsecond % backgroundImages.length];

    return ResponsiveBuilder(
      builder: (context) => Scaffold(
        body: ScreenBackground(
          imagePath: 'assets/images/$randomImage',
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveUtils.pSymmetric(horizontal: 20.0),
              child: SizedBox(
                width: 380.s,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title and Subtitle
                    Text(
                      ref.t(LocalizationKeys.welcomeBack),
                      style: TextStyle(
                        fontSize: 28.f,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5.s),
                    Text(
                      ref.t(LocalizationKeys.logInToContinue),
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 16.f,
                      ),
                    ),
                    SizedBox(height: 30.s),

                    // Input Fields
                    _buildInputField(
                      icon: FontAwesomeIcons.user,
                      hintText:
                          '${ref.t(LocalizationKeys.email)} ${ref.t(LocalizationKeys.username)}',
                      controller: usernameController,
                    ),
                    SizedBox(height: 20.s),
                    _buildInputField(
                      icon: FontAwesomeIcons.lock,
                      hintText: ref.t(LocalizationKeys.password),
                      controller: passwordController,
                      obscureText: true,
                    ),
                    SizedBox(height: 5.s),

                    // Forgot Password Link
                    _buildForgotPasswordLink(ref),
                    SizedBox(height: 20.s),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryActionButton(
                        text: ref.t(LocalizationKeys.logIn),
                        onTap: () async {
                          /*Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );*/
                          // Call the login method from the provider
                          await ref
                              .read(authControllerProvider.notifier)
                              .login(
                                usernameController.text.trim(),
                                passwordController.text.trim(),
                              );
                          /*print(
                            "Fetching user with tokens: ${ref.read(authControllerProvider).value != null ? 'TOKENS_AVAILABLE' : 'NO_TOKENS'}",
                          );*/
                        },
                      ),
                    ),
                    SizedBox(height: 30.s),

                    // Sign Up Link
                    _buildSignUpLink(context, ref),
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
    return GlassContainer(
      borderRadius: 12,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: AppColors.textLight, fontSize: 16.f),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 16.f),
          prefixIcon: Icon(icon, color: AppColors.textGrey, size: 18.s),
          contentPadding: ResponsiveUtils.pSymmetric(vertical: 15.0),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            // Handle forgot password logic
          },
          child: Text(
            ref.t(LocalizationKeys.forgotPassword),
            style: TextStyle(color: AppColors.textGrey, fontSize: 14.f),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink(BuildContext context, WidgetRef ref) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: AppColors.textGrey,
          fontSize: 14.f,
          fontFamily: 'Poppins',
        ),
        children: [
          TextSpan(text: "${ref.t(LocalizationKeys.dontHaveAccount)} "),
          TextSpan(
            text: ref.t(LocalizationKeys.signUp),
            style: TextStyle(
              color: AppColors.angolaYellow,
              fontWeight: FontWeight.w600,
              fontSize: 14.f,
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
