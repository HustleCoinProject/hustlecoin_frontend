import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/providers/foundational_providers.dart';
import 'package:hustlecoin/data/models/pending_reward.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';

class GlobalRewardListener extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalRewardListener({super.key, required this.child});

  @override
  ConsumerState<GlobalRewardListener> createState() =>
      _GlobalRewardListenerState();
}

class _GlobalRewardListenerState extends ConsumerState<GlobalRewardListener> {
  // Keep track of which rewards we're currently processing/showing
  // to avoid showing multiple popups for the same reward if state updates multiple times
  final Set<String> _processingRewardIds = {};

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the user object
    ref.listen(userControllerProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        final user = next.value!;

        // Check for any pending rewards we haven't processed yet
        if (user.pendingRewards.isNotEmpty) {
          for (final pendingReward in user.pendingRewards) {
            if (!_processingRewardIds.contains(pendingReward.id)) {
              _processReward(pendingReward);
            }
          }
        }
      }
    });

    return widget.child;
  }

  Future<void> _processReward(PendingReward reward) async {
    // Mark as processing
    _processingRewardIds.add(reward.id);

    // Show the popup
    // We use a microtask to ensure we don't try to show a dialog while the widget tree is still building
    Future.microtask(() {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false, // Force them to dismiss it via the button
        builder: (dialogContext) {
          // Wrap the actual content in an AlertDialog structure similar to GlobalRewardPopup
          // But here we need to insert the claim logic when they dismiss it
          return _PendingRewardDialogContent(
            reward: reward,
            onDismiss: () async {
              Navigator.of(dialogContext).pop();

              try {
                // Call API to claim the reward
                await ref
                    .read(dataRepositoryProvider)
                    .claimPendingReward(reward.id);

                // Once successfully claimed, we can remove it from our processing set
                // (Though it should also be removed from the user object via the refresh)
                _processingRewardIds.remove(reward.id);
              } catch (e) {
                // If claim fails, maybe allow them to try again later
                _processingRewardIds.remove(reward.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to claim reward: $e')),
                  );
                }
              }
            },
          );
        },
      );
    });
  }
}

// Internal widget just to reuse the styling logic of GlobalRewardPopup
// while giving us control over the dismiss action
class _PendingRewardDialogContent extends ConsumerWidget {
  final PendingReward reward;
  final VoidCallback onDismiss;

  const _PendingRewardDialogContent({
    required this.reward,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We basically cheat here and let GlobalRewardPopup render itself inside our builder,
    // but intercept the navigator pop?
    // Actually, it's cleaner to just show it directly but we need to know when it closes.
    // Let's just build the UI here directly to keep it simple and unified.

    return AlertDialog(
      backgroundColor: AppColors.uiDarkBg,
      title: Column(
        children: [
          Text(
            reward.source,
            style: TextStyle(
              color: AppColors.angolaYellow,
              fontSize: 14.f,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Icon(
            reward.reward.isItemReward
                ? FontAwesomeIcons.gift
                : FontAwesomeIcons.coins,
            color: AppColors.angolaYellow,
            size: 48.s,
          ),
          SizedBox(height: 12.h),
          Text(
            ref.t(LocalizationKeys.congratulationsExclaim),
            style: const TextStyle(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reward.reward.isHcReward) ...[
            Text(
              '${ref.t(LocalizationKeys.reward)} ${reward.reward.hcAmount} HC',
              style: TextStyle(
                color: Colors.green,
                fontSize: 20.f,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
            Text(
              ref.t(LocalizationKeys.youReceivedAnItem),
              style: TextStyle(color: AppColors.textLight, fontSize: 16.f),
            ),
            SizedBox(height: 8.h),
            Text(
              reward.reward.itemName ?? 'Unknown Item',
              style: TextStyle(
                color: AppColors.angolaYellow,
                fontSize: 18.f,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (reward.reward.itemDescription != null) ...[
              SizedBox(height: 4.h),
              Text(
                reward.reward.itemDescription!,
                style: TextStyle(color: AppColors.textGrey, fontSize: 14.f),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: Text(
            ref.t(LocalizationKeys.awesome),
            style: const TextStyle(color: AppColors.angolaYellow),
          ),
        ),
      ],
    );
  }
}
