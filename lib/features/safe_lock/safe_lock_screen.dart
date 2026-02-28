import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/safe_lock_claim_response.dart';
import 'package:hustlecoin/data/models/safe_lock_deposit_response.dart';
import 'package:hustlecoin/providers/safe_lock_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/primary_action_button.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/widgets/screen_header.dart';
import 'package:hustlecoin/widgets/global_reward_popup.dart';

class SafeLockScreen extends ConsumerStatefulWidget {
  const SafeLockScreen({super.key});

  @override
  ConsumerState<SafeLockScreen> createState() => _SafeLockScreenState();
}

class _SafeLockScreenState extends ConsumerState<SafeLockScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isDepositing = false;
  bool _isClaiming = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Future<void> _handleDeposit() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorDialog(ref.t(LocalizationKeys.pleaseEnterValidAmount));
      return;
    }

    final user = ref.read(userControllerProvider).value;
    if (user == null || user.hpScore < amount) {
      _showErrorDialog(ref.t(LocalizationKeys.insufficientBalance));
      return;
    }

    setState(() => _isDepositing = true);

    try {
      final response = await ref
          .read(safeLockStatusProvider.notifier)
          .deposit(amount);
      _amountController.clear();
      if (mounted) {
        _showSuccessDialog(response);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isDepositing = false);
      }
    }
  }

  Future<void> _handleClaim() async {
    setState(() => _isClaiming = true);

    try {
      final response = await ref.read(safeLockStatusProvider.notifier).claim();
      if (mounted) {
        _showRewardDialog(response);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isClaiming = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.uiDarkBg,
        title: Text(
          ref.t(LocalizationKeys.error),
          style: const TextStyle(color: AppColors.textLight),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.angolaYellow),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(SafeLockDepositResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.uiDarkBg,
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8.w),
            Text(
              ref.t(LocalizationKeys.success),
              style: const TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
        content: Text(
          response.message,
          style: const TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.angolaYellow),
            ),
          ),
        ],
      ),
    );
  }

  void _showRewardDialog(SafeLockClaimResponse response) {
    GlobalRewardPopup.show(
      context,
      ref,
      response.reward,
      returnedAmount: response.returnedAmount,
      newBalance: response.newBalance,
      source: "Safe Lock",
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userControllerProvider);
    final safeLockAsync = ref.watch(safeLockStatusProvider);
    final timeRemainingAsync = ref.watch(safeLockTimeRemainingProvider);

    final user = userAsync.value;

    return Scaffold(
      body: ScreenBackground(
        imagePath:
            'assets/images/${user != null ? HustleUtils.getCurrentHustleKey(user.currentHustle) : "Hustle Legend"}.jpg',
        child: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: ref.t(LocalizationKeys.safeLock),
                onBackTap: () => Navigator.pop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: ResponsiveUtils.p(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info Card
                      GlassContainer(
                        padding: ResponsiveUtils.p(20),
                        child: Column(
                          children: [
                            Icon(
                              FontAwesomeIcons.lockOpen,
                              color: AppColors.angolaYellow,
                              size: 48.s,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              ref.t(LocalizationKeys.safeLockSavings),
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 20.f,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '${ref.t(LocalizationKeys.lockYourHcForRewards)}\n${ref.t(LocalizationKeys.minimumRewardGuaranteed)}',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 14.f,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Global Stats
                      Consumer(
                        builder: (context, ref, child) {
                          final globalStatsAsync = ref.watch(
                            safeLockGlobalStatsProvider,
                          );
                          return globalStatsAsync.when(
                            data: (stats) => GlassContainer(
                              padding: ResponsiveUtils.pSymmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStockStyleStat(
                                    'GLOBAL LOCKED',
                                    '${(stats.totalSafeLockGlobal / 1000).toStringAsFixed(1)}K',
                                    true,
                                    '--%',
                                  ),
                                  _buildStockStyleStat(
                                    'USERS',
                                    '${stats.totalUsersWithSafeLock}',
                                    true,
                                    '--%',
                                  ),
                                  _buildStockStyleStat(
                                    'AVG',
                                    '${(stats.averageSafeLockAmount / 1000).toStringAsFixed(1)}K',
                                    false,
                                    '--%',
                                  ),
                                ],
                              ),
                            ),
                            loading: () => GlassContainer(
                              padding: ResponsiveUtils.p(16),
                              child: Center(
                                child: SizedBox(
                                  height: 20.s,
                                  width: 20.s,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            error: (e, _) => GlassContainer(
                              padding: ResponsiveUtils.p(16),
                              child: Text(
                                'Global stats unavailable',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12.f,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 20.h),

                      // Current Balance
                      userAsync.when(
                        data: (user) => GlassContainer(
                          padding: ResponsiveUtils.p(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ref.t(LocalizationKeys.yourBalance),
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 16.f,
                                ),
                              ),
                              Text(
                                '${user?.hpScore ?? 0} HP',
                                style: TextStyle(
                                  color: AppColors.angolaYellow,
                                  fontSize: 18.f,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text(
                          'Error: $e',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Safe Lock Status
                      safeLockAsync.when(
                        data: (status) => GlassContainer(
                          padding: ResponsiveUtils.p(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ref.t(LocalizationKeys.lockedAmount),
                                    style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 16.f,
                                    ),
                                  ),
                                  Text(
                                    '${status.safeLockAmount} HP',
                                    style: TextStyle(
                                      color: status.safeLockAmount > 0
                                          ? Colors.green
                                          : AppColors.textLight,
                                      fontSize: 20.f,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (status.isLocked) ...[
                                SizedBox(height: 16.h),
                                Divider(color: AppColors.glassBorder),
                                SizedBox(height: 16.h),
                                Row(
                                  children: [
                                    Icon(
                                      status.canClaim
                                          ? Icons.lock_open
                                          : Icons.lock,
                                      color: status.canClaim
                                          ? Colors.green
                                          : AppColors.angolaRed,
                                      size: 20.s,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      status.canClaim
                                          ? ref.t(LocalizationKeys.readyToClaim)
                                          : ref.t(LocalizationKeys.locked),
                                      style: TextStyle(
                                        color: status.canClaim
                                            ? Colors.green
                                            : AppColors.textLight,
                                        fontSize: 16.f,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                if (!status.canClaim &&
                                    status.lockedUntil != null) ...[
                                  timeRemainingAsync.when(
                                    data: (duration) => Column(
                                      children: [
                                        Text(
                                          ref.t(LocalizationKeys.timeRemaining),
                                          style: TextStyle(
                                            color: AppColors.textGrey,
                                            fontSize: 14.f,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          _formatDuration(duration),
                                          style: TextStyle(
                                            color: AppColors.angolaYellow,
                                            fontSize: 24.f,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        LinearProgressIndicator(
                                          value:
                                              1 -
                                              (duration.inSeconds /
                                                  (7 * 24 * 60 * 60)),
                                          backgroundColor:
                                              AppColors.glassBorder,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(AppColors.angolaYellow),
                                        ),
                                      ],
                                    ),
                                    loading: () =>
                                        const CircularProgressIndicator(),
                                    error: (_, __) => const SizedBox.shrink(),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => GlassContainer(
                          padding: ResponsiveUtils.p(20),
                          child: Text(
                            'Error loading status: $e',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Deposit Section
                      safeLockAsync.maybeWhen(
                        data: (status) => status.canClaim
                            ? PrimaryActionButton(
                                text: ref.t(LocalizationKeys.claimRewards),
                                onTap: _handleClaim,
                                isLoading: _isClaiming,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    ref.t(LocalizationKeys.depositAmount),
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 16.f,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  GlassContainer(
                                    padding: ResponsiveUtils.pSymmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 18.f,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: ref.t(
                                          LocalizationKeys.enterHcAmount,
                                        ),
                                        hintStyle: TextStyle(
                                          color: AppColors.textGrey,
                                          fontSize: 16.f,
                                        ),
                                        border: InputBorder.none,
                                        suffixText: 'HP',
                                        suffixStyle: TextStyle(
                                          color: AppColors.angolaYellow,
                                          fontSize: 16.f,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  PrimaryActionButton(
                                    text: status.safeLockAmount > 0
                                        ? ref.t(
                                            LocalizationKeys.addMoreTimerResets,
                                          )
                                        : ref.t(
                                            LocalizationKeys.depositToSafeLock,
                                          ),
                                    onTap: _handleDeposit,
                                    isLoading: _isDepositing,
                                  ),
                                  if (status.safeLockAmount > 0) ...[
                                    SizedBox(height: 8.h),
                                    Text(
                                      ref.t(
                                        LocalizationKeys
                                            .depositingAgainResetsTimer,
                                      ),
                                      style: TextStyle(
                                        color: AppColors.angolaRed,
                                        fontSize: 12.f,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                        orElse: () => const SizedBox.shrink(),
                      ),

                      SizedBox(height: 24.h),

                      // How it Works Section
                      GlassContainer(
                        padding: ResponsiveUtils.p(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.t(LocalizationKeys.howItWorks),
                              style: TextStyle(
                                color: AppColors.angolaYellow,
                                fontSize: 18.f,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _buildInfoPoint(
                              '🔒',
                              ref.t(LocalizationKeys.safeLockInfo1),
                            ),
                            _buildInfoPoint(
                              '⏰',
                              ref.t(LocalizationKeys.safeLockInfo2),
                            ),
                            _buildInfoPoint(
                              '💰',
                              ref.t(LocalizationKeys.safeLockInfo3),
                            ),
                            _buildInfoPoint(
                              '🎁',
                              ref.t(LocalizationKeys.safeLockInfo4),
                            ),
                            _buildInfoPoint(
                              '✅',
                              ref.t(LocalizationKeys.safeLockInfo5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String icon, String text) {
    return Padding(
      padding: ResponsiveUtils.pSymmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: 16.f)),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.textLight, fontSize: 14.f),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: 20.f)),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: AppColors.angolaYellow,
            fontSize: 16.f,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(color: AppColors.textGrey, fontSize: 10.f),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStockStyleStat(
    String label,
    String value,
    bool isPositive,
    String change,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 9.f,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16.f,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: isPositive ? Colors.green : Colors.red,
              size: 16.s,
            ),
            Text(
              change,
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontSize: 10.f,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
