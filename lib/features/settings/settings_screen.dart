import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/user.dart';
import 'package:hustlecoin/features/settings/credits_screen.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/widgets/screen_header.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State providers for settings
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final soundEffectsEnabledProvider = StateProvider<bool>((ref) => true);
final autoCollectRewardsProvider = StateProvider<bool>((ref) => false);
final hapticFeedbackProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    ref.read(notificationsEnabledProvider.notifier).state =
        prefs.getBool('notifications_enabled') ?? true;
    ref.read(soundEffectsEnabledProvider.notifier).state =
        prefs.getBool('sound_effects_enabled') ?? true;
    ref.read(autoCollectRewardsProvider.notifier).state =
        prefs.getBool('auto_collect_rewards') ?? false;
    ref.read(hapticFeedbackProvider.notifier).state =
        prefs.getBool('haptic_feedback') ?? true;
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    final user = userState.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );

    return ResponsiveBuilder(
      builder: (context) => Scaffold(
        body: ScreenBackground(
          imagePath:
              'assets/images/${user != null ? HustleUtils.getCurrentHustleKey(user.currentHustle) : "Taxi Driver"}.jpg',
          child: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: ref.t(LocalizationKeys.settings).toUpperCase(),
                  showBackButton: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: ResponsiveUtils.pSymmetric(
                      horizontal: 15.0,
                      vertical: 10.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle(ref.t(LocalizationKeys.general)),
                        SizedBox(height: 10.s),
                        _buildSettingToggle(
                          icon: FontAwesomeIcons.bell,
                          title: ref.t(LocalizationKeys.pushNotifications),
                          subtitle: ref.t(LocalizationKeys.pushNotificationsDesc),
                          provider: notificationsEnabledProvider,
                          onChanged: (value) {
                            ref
                                    .read(notificationsEnabledProvider.notifier)
                                    .state =
                                value;
                            _saveSetting('notifications_enabled', value);
                          },
                        ),
                        SizedBox(height: 12.s),
                        _buildSettingToggle(
                          icon: FontAwesomeIcons.volumeHigh,
                          title: ref.t(LocalizationKeys.soundEffects),
                          subtitle: ref.t(LocalizationKeys.soundEffectsDesc),
                          provider: soundEffectsEnabledProvider,
                          onChanged: (value) {
                            ref
                                    .read(soundEffectsEnabledProvider.notifier)
                                    .state =
                                value;
                            _saveSetting('sound_effects_enabled', value);
                            if (value) {
                              SoundService().playClick();
                            }
                          },
                        ),
                        SizedBox(height: 12.s),
                        _buildSettingToggle(
                          icon: FontAwesomeIcons.mobile,
                          title: ref.t(LocalizationKeys.hapticFeedback),
                          subtitle: ref.t(LocalizationKeys.hapticFeedbackDesc),
                          provider: hapticFeedbackProvider,
                          onChanged: (value) {
                            ref.read(hapticFeedbackProvider.notifier).state =
                                value;
                            _saveSetting('haptic_feedback', value);
                          },
                        ),
                        SizedBox(height: 24.s),
                        _buildSectionTitle(ref.t(LocalizationKeys.gameplay)),
                        SizedBox(height: 10.s),
                        _buildSettingToggle(
                          icon: FontAwesomeIcons.gifts,
                          title: ref.t(LocalizationKeys.autoCollectRewards),
                          subtitle: ref.t(LocalizationKeys.autoCollectRewardsDesc),
                          provider: autoCollectRewardsProvider,
                          onChanged: (value) {
                            ref
                                    .read(autoCollectRewardsProvider.notifier)
                                    .state =
                                value;
                            _saveSetting('auto_collect_rewards', value);
                          },
                        ),
                        SizedBox(height: 24.s),
                        _buildSectionTitle(ref.t(LocalizationKeys.about)),
                        SizedBox(height: 10.s),
                        _buildNavigationItem(
                          icon: FontAwesomeIcons.info,
                          title: ref.t(LocalizationKeys.credits),
                          subtitle: ref.t(LocalizationKeys.creditsDesc),
                          onTap: () {
                            SoundService().playClick();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CreditsScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12.s),
                        _buildInfoItem(
                          icon: FontAwesomeIcons.circleInfo,
                          title: ref.t(LocalizationKeys.appVersion),
                          subtitle: '1.0.0',
                        ),
                        SizedBox(height: 24.s),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: ResponsiveUtils.pSymmetric(horizontal: 8.0, vertical: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.f,
          fontWeight: FontWeight.w700,
          color: AppColors.angolaYellow,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required StateProvider<bool> provider,
    required ValueChanged<bool> onChanged,
  }) {
    final isEnabled = ref.watch(provider);

    return GlassContainer(
      borderRadius: 12,
      padding: ResponsiveUtils.pSymmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Container(
            width: 40.s,
            height: 40.s,
            decoration: BoxDecoration(
              color: AppColors.angolaYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: FaIcon(icon, size: 18.s, color: AppColors.angolaYellow),
            ),
          ),
          SizedBox(width: 12.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.f,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(height: 2.s),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.f, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: AppColors.angolaYellow,
            activeTrackColor: AppColors.angolaYellow.withValues(alpha: 0.5),
            inactiveThumbColor: AppColors.textGrey,
            inactiveTrackColor: AppColors.textGrey.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return PressableScaleWidget(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: 12,
        padding: ResponsiveUtils.pSymmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 40.s,
              height: 40.s,
              decoration: BoxDecoration(
                color: AppColors.angolaRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: FaIcon(icon, size: 18.s, color: AppColors.angolaRed),
              ),
            ),
            SizedBox(width: 12.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.f,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                    ),
                  ),
                  SizedBox(height: 2.s),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11.f, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 14.s,
              color: AppColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return GlassContainer(
      borderRadius: 12,
      padding: ResponsiveUtils.pSymmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Container(
            width: 40.s,
            height: 40.s,
            decoration: BoxDecoration(
              color: AppColors.textGrey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: FaIcon(icon, size: 18.s, color: AppColors.textGrey),
            ),
          ),
          SizedBox(width: 12.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.f,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
                SizedBox(height: 2.s),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.f, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
