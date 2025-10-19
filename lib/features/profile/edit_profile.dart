import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/features/auth/start_screen.dart';
import 'package:hustlecoin/providers/auth_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/providers/user_specific_data_provider.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/primary_action_button.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/widgets/screen_header.dart';

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
        // Handle both old string format and new object format
        _selectedHustle = HustleUtils.getCurrentHustleKey(user.currentHustle);
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
        _errorMessage = ref.t(LocalizationKeys.passwordsDontMatch);
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
    // Use the hustle key for the background image
    final hustleKey = user != null
        ? HustleUtils.getCurrentHustleKey(user.currentHustle)
        : "Taxi Driver";

    return Scaffold(
      body: ScreenBackground(
        imagePath: 'assets/images/$hustleKey.png',
        child: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: ref.t(LocalizationKeys.viewEditProfile),
                trailingWidget: PressableScaleWidget(
                  onTap: () {
                    // Handle logout logic
                    ref.read(authControllerProvider.notifier).logout();
                    // Navigate to StartScreen and remove all previous routes
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const StartScreen()),
                      (route) => false, // This removes all previous routes
                    );
                  },
                  child: const GlassContainer(
                    borderRadius: 12,
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: Icon(FontAwesomeIcons.signOutAlt, size: 20),
                    ),
                  ),
                ),
              ),
              _buildContent(),
            ],
          ),
        ),
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
          child: const GlassContainer(
            shape: BoxShape.circle,
            child: Center(child: Text('😎', style: TextStyle(fontSize: 60))),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: PressableScaleWidget(
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
          '${ref.t(LocalizationKeys.errorLoadingProfile)}: ${user.error}',
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
              label: ref.t(LocalizationKeys.username),
              child: GlassContainer(
                borderRadius: 10,
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
              label: ref.t(LocalizationKeys.emailAddress),
              child: _buildTextField(
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return ref.t(LocalizationKeys.emailIsRequired);
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return ref.t(LocalizationKeys.pleaseEnterValidEmail);
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 15),

            // Language selector
            _buildInputField(
              label: ref.t(LocalizationKeys.language),
              child: _buildLanguageSelector(),
            ),
            const SizedBox(height: 15),

            // Current hustle selector
            _buildInputField(
              label: ref.t(LocalizationKeys.currentHustle),
              child: availableHustles.when(
                data: (hustles) => _buildHustleSelector(hustles),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text(
                  '${ref.t(LocalizationKeys.errorLoadingHustles)}: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // --- Change Password Section ---
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
              child: Text(
                ref.t(LocalizationKeys.changePassword),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.2),
              margin: const EdgeInsets.only(bottom: 15),
            ),

            _buildInputField(
              label: ref.t(LocalizationKeys.currentPassword),
              child: _buildTextField(
                hint: ref.t(LocalizationKeys.enterCurrentPassword),
                obscure: true,
                controller: _currentPasswordController,
              ),
            ),
            const SizedBox(height: 15),
            _buildInputField(
              label: ref.t(LocalizationKeys.newPassword),
              child: _buildTextField(
                hint: ref.t(LocalizationKeys.enterNewPassword),
                obscure: true,
                controller: _newPasswordController,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    if (_currentPasswordController.text.isEmpty) {
                      return ref.t(LocalizationKeys.currentPasswordRequired);
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 15),
            _buildInputField(
              label: ref.t(LocalizationKeys.confirmNewPassword),
              child: _buildTextField(
                hint: ref.t(LocalizationKeys.confirmNewPasswordHint),
                obscure: true,
                controller: _confirmNewPasswordController,
                validator: (value) {
                  if (_newPasswordController.text.isNotEmpty &&
                      value != _newPasswordController.text) {
                    return ref.t(LocalizationKeys.passwordsDoNotMatch);
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
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  ref.t(LocalizationKeys.profileUpdatedSuccessfully),
                  style: const TextStyle(color: Colors.green),
                ),
              ),

            // --- Update Button ---
            SizedBox(
              width: double.infinity, // Wrap in SizedBox to enforce full width
              child: PrimaryActionButton(
                text: ref.t(LocalizationKeys.updateProfile),
                onTap: _saveProfile,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return GlassContainer(
      borderRadius: 10,
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [_buildLanguageOption('en'), _buildLanguageOption('pt')],
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

  Widget _buildHustleSelector(Map<String, String> availableHustles) {
    return GlassContainer(
      borderRadius: 10,
      child: DropdownButtonFormField<String>(
        value: _selectedHustle,
        dropdownColor: AppColors.glassBg,
        style: const TextStyle(color: AppColors.textLight),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
        items: availableHustles.entries.map((entry) {
          // entry.key = English name (hustle key)
          // entry.value = Localized name (display name)
          return DropdownMenuItem<String>(
            value: entry.key, // Store the key (English name)
            child: Text(entry.value), // Display the localized name
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedHustle = value; // This will be the key (English name)
          });
        },
        hint: Text(
          ref.t(LocalizationKeys.selectYourHustle),
          style: const TextStyle(color: AppColors.textGrey),
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
    return GlassContainer(
      borderRadius: 10,
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
