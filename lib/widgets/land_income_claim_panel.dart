import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../data/models/land_claim_status.dart';
import '../providers/land_provider.dart';
import '../providers/user_provider.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';
import '../utils/localization.dart';
import '../utils/time_utils.dart';
import '../widgets/glass_container.dart';

class LandIncomeClaimPanel extends ConsumerStatefulWidget {
  const LandIncomeClaimPanel({super.key});

  @override
  ConsumerState<LandIncomeClaimPanel> createState() =>
      _LandIncomeClaimPanelState();
}

class _LandIncomeClaimPanelState extends ConsumerState<LandIncomeClaimPanel> {
  bool _isClaiming = false;
  Timer? _countdownTimer;
  int? _currentCountdownSeconds;

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    // Update countdown every second for a real-time feel
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final claimStatusAsync = ref.read(landClaimStatusProvider);
        claimStatusAsync.whenData((claimStatus) {
          if (claimStatus != null &&
              claimStatus.timeUntilNextClaimSeconds != null &&
              claimStatus.timeUntilNextClaimSeconds! > 0) {
            setState(() {
              _currentCountdownSeconds =
                  claimStatus.timeUntilNextClaimSeconds! - 1;
            });

            // If countdown reaches 0, refresh the provider to get updated status
            if (_currentCountdownSeconds! <= 0) {
              ref.invalidate(landClaimStatusProvider);
              setState(() {
                _currentCountdownSeconds = null;
              });
            }
          } else {
            setState(() {
              _currentCountdownSeconds = null;
            });
          }
        });
      }
    });
  }

  Future<void> _claimLandIncome() async {
    if (_isClaiming) return;

    setState(() => _isClaiming = true);

    try {
      await ref.read(userControllerProvider.notifier).claimLandIncome();

      if (mounted) {
        // Play success sound
        SoundService().playEarnCoins();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.t(LocalizationKeys.landIncomeClaimedSuccessfully),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the claim status
        ref.invalidate(landClaimStatusProvider);
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${ref.t(LocalizationKeys.landIncomeClaimFailed)}: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isClaiming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final claimStatusAsync = ref.watch(landClaimStatusProvider);

    return claimStatusAsync.when(
      data: (claimStatus) {
        if (claimStatus == null) {
          // User has no land, don't show claim panel
          return const SizedBox.shrink();
        }

        return _buildClaimPanel(claimStatus);
      },
      loading: () => _buildLoadingPanel(),
      error: (error, stack) => _buildErrorPanel(error.toString()),
    );
  }

  Widget _buildLoadingPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text(
            'Loading land status...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPanel(String error) {
    return GlassContainer(
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Error loading claim status',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimPanel(LandClaimStatus claimStatus) {
    final canClaim = claimStatus.canClaim && claimStatus.availableIncome > 0;
    final hasIncome = claimStatus.availableIncome > 0;
    final onCooldown =
        !claimStatus.canClaim &&
        claimStatus.timeUntilNextClaimSeconds != null &&
        claimStatus.timeUntilNextClaimSeconds! > 0;

    // Use real-time countdown if available, otherwise use server value
    final countdownSeconds =
        _currentCountdownSeconds ?? claimStatus.timeUntilNextClaimSeconds;

    return GlassContainer(
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              // Status icon
              _buildStatusIcon(canClaim, onCooldown, hasIncome),
              const SizedBox(width: 10),
              // Main content
              Expanded(
                child: _buildMainContent(
                  claimStatus,
                  canClaim,
                  hasIncome,
                  onCooldown,
                  countdownSeconds,
                ),
              ),
              const SizedBox(width: 10),
              // Action button
              _buildActionButton(canClaim, onCooldown, countdownSeconds),
            ],
          ),
          // Additional info row
          if (claimStatus.lastClaimAt != null ||
              (onCooldown && countdownSeconds != null && countdownSeconds > 0))
            _buildInfoRow(claimStatus, onCooldown, countdownSeconds),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(bool canClaim, bool onCooldown, bool hasIncome) {
    if (canClaim && hasIncome) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1500),
        tween: Tween(begin: 0.9, end: 1.1),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: const FaIcon(
              FontAwesomeIcons.coins,
              color: AppColors.angolaYellow,
              size: 18,
            ),
          );
        },
        onEnd: () {
          // Restart animation for pulsing effect
          setState(() {});
        },
      );
    } else if (onCooldown) {
      return const Icon(Icons.timer_outlined, color: Colors.orange, size: 20);
    } else {
      return const Icon(Icons.landscape_outlined, color: Colors.grey, size: 20);
    }
  }

  Widget _buildMainContent(
    LandClaimStatus claimStatus,
    bool canClaim,
    bool hasIncome,
    bool onCooldown,
    int? countdownSeconds,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary status text
        Text(
          _getPrimaryStatusText(claimStatus, canClaim, hasIncome),
          style: TextStyle(
            color: canClaim && hasIncome
                ? AppColors.angolaYellow
                : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Secondary status text
        if (_getSecondaryStatusText(
              claimStatus,
              onCooldown,
              countdownSeconds,
            ) !=
            null)
          Text(
            _getSecondaryStatusText(claimStatus, onCooldown, countdownSeconds)!,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  String _getPrimaryStatusText(
    LandClaimStatus claimStatus,
    bool canClaim,
    bool hasIncome,
  ) {
    if (canClaim && hasIncome) {
      return '${claimStatus.availableIncome} HP ${ref.t(LocalizationKeys.readyToClaim)}!';
    } else if (claimStatus.availableIncome == 0 && claimStatus.tilesCount > 0) {
      return ref.t(LocalizationKeys.noIncomeAvailable);
    } else if (claimStatus.availableIncome > 0 && !canClaim) {
      return '${claimStatus.availableIncome} HP ${ref.t(LocalizationKeys.claimAvailable)}';
    } else {
      return '${claimStatus.tilesCount} ${ref.t(LocalizationKeys.landTiles)}';
    }
  }

  String? _getSecondaryStatusText(
    LandClaimStatus claimStatus,
    bool onCooldown,
    int? countdownSeconds,
  ) {
    if (onCooldown && countdownSeconds != null && countdownSeconds > 0) {
      return '${ref.t(LocalizationKeys.nextClaimIn)} ${formatDuration(countdownSeconds)}';
    } else if (claimStatus.availableIncome > 0 &&
        !claimStatus.canClaim &&
        !onCooldown) {
      return '${claimStatus.availableIncome} HP ${ref.t(LocalizationKeys.claimAvailable)}';
    } else if (claimStatus.tilesCount > 0 && claimStatus.availableIncome == 0) {
      return '${claimStatus.tilesCount} ${ref.t(LocalizationKeys.landTiles)} ${ref.t(LocalizationKeys.generatingIncome)}';
    }
    return null;
  }

  Widget _buildActionButton(
    bool canClaim,
    bool onCooldown,
    int? countdownSeconds,
  ) {
    final isEnabled = canClaim && !_isClaiming;
    final buttonText = _getButtonText(canClaim, onCooldown, countdownSeconds);

    return GestureDetector(
      onTap: isEnabled
          ? () {
              SoundService().playClick();
              _claimLandIncome();
            }
          : () {
              // Provide haptic feedback for disabled button taps
              if (!isEnabled && !_isClaiming) {
                SoundService().playClick();
                // Show feedback about why claim is not available
                if (onCooldown &&
                    countdownSeconds != null &&
                    countdownSeconds > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${ref.t(LocalizationKeys.nextClaimIn)} ${formatDuration(countdownSeconds)}',
                      ),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
                  colors: [AppColors.angolaYellow, AppColors.angolaRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !isEnabled ? Colors.grey.shade800 : null,
          borderRadius: BorderRadius.circular(10),
          border: onCooldown
              ? Border.all(color: Colors.orange.withOpacity(0.5), width: 1)
              : null,
        ),
        child: _isClaiming
            ? const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onCooldown &&
                      countdownSeconds != null &&
                      countdownSeconds > 0)
                    const Icon(Icons.timer, color: Colors.white, size: 12),
                  if (onCooldown &&
                      countdownSeconds != null &&
                      countdownSeconds > 0)
                    const SizedBox(width: 4),
                  if (isEnabled)
                    const Icon(Icons.star, color: Colors.white, size: 12),
                  if (isEnabled) const SizedBox(width: 4),
                  Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _getButtonText(bool canClaim, bool onCooldown, int? countdownSeconds) {
    if (_isClaiming) return '';

    if (canClaim) {
      return ref.t(LocalizationKeys.claim);
    } else if (onCooldown) {
      return ref.t(LocalizationKeys.claimCooldown);
    } else {
      return ref.t(LocalizationKeys.claimCooldown);
    }
  }

  Widget _buildInfoRow(
    LandClaimStatus claimStatus,
    bool onCooldown,
    int? countdownSeconds,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const SizedBox(width: 28), // Align with main content
          Expanded(
            child: Row(
              children: [
                if (claimStatus.lastClaimAt != null) ...[
                  Icon(Icons.history, color: Colors.grey.shade500, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '${ref.t(LocalizationKeys.lastClaimedAt)}: ${_formatLastClaimTime(claimStatus.lastClaimAt!)}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                if (claimStatus.tilesCount > 0 &&
                    claimStatus.lastClaimAt != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.terrain, color: Colors.grey.shade500, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '${claimStatus.tilesCount} ${ref.t(LocalizationKeys.landTiles)}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastClaimTime(DateTime lastClaimAt) {
    final now = DateTime.now();
    final difference = now.difference(lastClaimAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
