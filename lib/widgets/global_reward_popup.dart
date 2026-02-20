import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/app_reward.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';

class GlobalRewardPopup {
  static void show(
    BuildContext context,
    WidgetRef ref,
    AppReward reward, {
    int? returnedAmount,
    int? newBalance,
    String? source,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.uiDarkBg,
        title: Column(
          children: [
            if (source != null) ...[
              Text(
                source,
                style: TextStyle(
                  color: AppColors.angolaYellow,
                  fontSize: 14.f,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
            ],
            Icon(
              reward.isItemReward
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
            if (returnedAmount != null) ...[
              Text(
                '${ref.t(LocalizationKeys.returned)} $returnedAmount HC',
                style: TextStyle(
                  color: AppColors.angolaYellow,
                  fontSize: 18.f,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
            ],
            if (reward.isHcReward) ...[
              Text(
                '${ref.t(LocalizationKeys.reward)} ${reward.hcAmount} HC',
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
                reward.itemName ?? 'Unknown Item',
                style: TextStyle(
                  color: AppColors.angolaYellow,
                  fontSize: 18.f,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (reward.itemDescription != null) ...[
                SizedBox(height: 4.h),
                Text(
                  reward.itemDescription!,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 14.f),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
            if (newBalance != null) ...[
              SizedBox(height: 16.h),
              Text(
                '${ref.t(LocalizationKeys.newBalance)} $newBalance HC',
                style: TextStyle(color: AppColors.textLight, fontSize: 16.f),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              ref.t(LocalizationKeys.awesome),
              style: const TextStyle(color: AppColors.angolaYellow),
            ),
          ),
        ],
      ),
    );
  }
}
