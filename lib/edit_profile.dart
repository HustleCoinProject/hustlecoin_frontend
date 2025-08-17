import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'app_colors.dart'; // Assuming you have this file from previous steps

// --- Reusable Helper Widgets ---

// High-performance "smoky glass" container without blur
class _GlassEffectContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final BoxShape shape;

  const _GlassEffectContainer({
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.padding = EdgeInsets.zero,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        shape: shape,
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

// --- Main Edit Profile Screen Widget ---

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

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
          child: SafeArea(
            child: Column(children: [_buildHeader(context), _buildContent()]),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: [
          PressableWidget(
            onTap: () => Navigator.of(context).pop(),
            child: const _GlassEffectContainer(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: SizedBox(
                width: 54,
                height: 54,
                child: Icon(FontAwesomeIcons.arrowLeft, size: 20),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'View/Edit Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
              ),
            ),
          ),
          PressableWidget(
            onTap: () {
              // Handle logout logic
            },
            child: const _GlassEffectContainer(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: SizedBox(
                width: 54,
                height: 54,
                child: Icon(FontAwesomeIcons.signOutAlt, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildAvatar(),
            const SizedBox(height: 25),
            _buildProfileForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.angolaYellow, width: 3),
          ),
          child: const _GlassEffectContainer(
            shape: BoxShape.circle,
            child: Center(child: Text('😎', style: TextStyle(fontSize: 60))),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: PressableWidget(
            onTap: () {
              // Handle change avatar logic
            },
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: AppColors.angolaYellow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.angolaBlack, width: 2),
              ),
              child: const Icon(
                FontAwesomeIcons.camera,
                size: 16,
                color: AppColors.angolaBlack,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return SizedBox(
      width: 380,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(
            label: 'Username',
            child: _GlassEffectContainer(
              borderRadius: BorderRadius.circular(10),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: const Row(
                children: [
                  Icon(
                    FontAwesomeIcons.lock,
                    size: 16,
                    color: AppColors.angolaYellow,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'YourUsername',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildInputField(
            label: 'Email Address',
            child: _buildTextField(initialValue: 'user@example.com'),
          ),
          const SizedBox(height: 15),

          // --- Change Password Section ---
          const Padding(
            padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
            child: Text(
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
            margin: const EdgeInsets.only(bottom: 15),
          ),

          _buildInputField(
            label: 'Current Password',
            child: _buildTextField(
              hint: 'Enter current password',
              obscure: true,
            ),
          ),
          const SizedBox(height: 15),
          _buildInputField(
            label: 'New Password',
            child: _buildTextField(hint: 'Enter new password', obscure: true),
          ),
          const SizedBox(height: 15),
          _buildInputField(
            label: 'Confirm New Password',
            child: _buildTextField(hint: 'Confirm new password', obscure: true),
          ),
          const SizedBox(height: 30),

          // --- Update Button ---
          PressableWidget(
            onTap: () {
              // Handle update profile logic
            },
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
              child: const Text(
                'Update Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for a label + input field group
  Widget _buildInputField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }

  // Helper for styling the text fields
  Widget _buildTextField({
    String? initialValue,
    String? hint,
    bool obscure = false,
  }) {
    return _GlassEffectContainer(
      borderRadius: BorderRadius.circular(10),
      child: TextFormField(
        initialValue: initialValue,
        obscureText: obscure,
        style: const TextStyle(color: AppColors.textLight, fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textGrey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
