import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_colors.dart';
import 'state/all_states.dart';
import 'start.dart';

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

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmNewPasswordController;

  String _selectedLanguage = 'EN';
  String? _selectedHustle;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();

    // Initialize with user data after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initUserData();
    });
  }

  void _initUserData() {
    final user = ref.read(userControllerProvider).value;
    if (user != null) {
      _emailController.text = user.email;
      setState(() {
        _selectedLanguage = user.language;
        _selectedHustle = user.currentHustle;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_newPasswordController.text.isNotEmpty &&
        _newPasswordController.text != _confirmNewPasswordController.text) {
      setState(() {
        _errorMessage = "New password and confirmation don't match";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isSuccess = false;
    });

    try {
      await ref
          .read(userControllerProvider.notifier)
          .updateProfile(
            email: _emailController.text,
            currentPassword: _currentPasswordController.text.isNotEmpty
                ? _currentPasswordController.text
                : null,
            newPassword: _newPasswordController.text.isNotEmpty
                ? _newPasswordController.text
                : null,
            language: _selectedLanguage,
            currentHustle: _selectedHustle,
          );

      setState(() {
        _isSuccess = true;
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userControllerProvider).value;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/${user?.currentHustle ?? "Taxi Driver"}.png',
            ),
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
              ref.read(authControllerProvider.notifier).logout();
              // Navigate to StartScreen and remove all previous routes
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const StartScreen()),
                (route) => false, // This removes all previous routes
              );
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
    final user = ref.watch(userControllerProvider);
    final availableHustles = ref.watch(availableHustlesProvider);

    // Show loading indicator while loading user data
    if (user.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error if we failed to load user data
    if (user.hasError) {
      return Center(
        child: Text(
          'Error loading profile: ${user.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return SizedBox(
      width: 380,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username (read-only)
            _buildInputField(
              label: 'Username',
              child: _GlassEffectContainer(
                borderRadius: BorderRadius.circular(10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.lock,
                      size: 16,
                      color: AppColors.angolaYellow,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      user.value?.username ?? 'Username',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Email address
            _buildInputField(
              label: 'Email Address',
              child: _buildTextField(
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 15),

            // Language selector
            _buildInputField(
              label: 'Language',
              child: _buildLanguageSelector(),
            ),
            const SizedBox(height: 15),

            // Current hustle selector
            _buildInputField(
              label: 'Current Hustle',
              child: availableHustles.when(
                data: (hustles) => _buildHustleSelector(hustles),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text(
                  'Error loading hustles: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
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
                controller: _currentPasswordController,
              ),
            ),
            const SizedBox(height: 15),
            _buildInputField(
              label: 'New Password',
              child: _buildTextField(
                hint: 'Enter new password',
                obscure: true,
                controller: _newPasswordController,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    if (_currentPasswordController.text.isEmpty) {
                      return 'Current password is required to change password';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 15),
            _buildInputField(
              label: 'Confirm New Password',
              child: _buildTextField(
                hint: 'Confirm new password',
                obscure: true,
                controller: _confirmNewPasswordController,
                validator: (value) {
                  if (_newPasswordController.text.isNotEmpty &&
                      value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 15),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Success message
            if (_isSuccess)
              const Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Text(
                  'Profile updated successfully!',
                  style: TextStyle(color: Colors.green),
                ),
              ),

            // --- Update Button ---
            PressableWidget(
              onTap: _isLoading ? null : _saveProfile,
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
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const Text(
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
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return _GlassEffectContainer(
      borderRadius: BorderRadius.circular(10),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [_buildLanguageOption('EN'), _buildLanguageOption('PT')],
      ),
    );
  }

  Widget _buildLanguageOption(String lang) {
    final isSelected = _selectedLanguage == lang;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedLanguage = lang),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.angolaYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            lang,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.angolaBlack : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHustleSelector(List<String> availableHustles) {
    return _GlassEffectContainer(
      borderRadius: BorderRadius.circular(10),
      child: DropdownButtonFormField<String>(
        value: _selectedHustle,
        dropdownColor: AppColors.glassBg,
        style: const TextStyle(color: AppColors.textLight),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
        items: availableHustles.map((hustle) {
          return DropdownMenuItem<String>(value: hustle, child: Text(hustle));
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedHustle = value;
          });
        },
        hint: const Text(
          'Select your hustle',
          style: TextStyle(color: AppColors.textGrey),
        ),
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
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return _GlassEffectContainer(
      borderRadius: BorderRadius.circular(10),
      child: TextFormField(
        initialValue: controller == null ? initialValue : null,
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: const TextStyle(color: AppColors.textLight, fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textGrey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 12,
          ),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    );
  }
}
