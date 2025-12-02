import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/inventory_item_out.dart';
import 'package:hustlecoin/providers/user_specific_data_provider.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/widgets/screen_header.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/providers/time_provider.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/widgets/banner_ad_widget.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userControllerProvider);
    final user = userState.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );
    final inventoryAsync = ref.watch(inventoryProvider);

    return Scaffold(
      body: ScreenBackground(
        imagePath: user != null
            ? 'assets/images/${HustleUtils.getCurrentHustleKey(user.currentHustle)}.jpg'
            : 'assets/images/Taxi Driver.jpg',
        child: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: ref.t(LocalizationKeys.inventory),
                onBackTap: () {
                  SoundService().playClick();
                  Navigator.of(context).pop();
                },
              ),

              // Banner ad
              const BannerAdWidget(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              ),

              // Inventory content
              Expanded(
                child: Padding(
                  padding: ResponsiveUtils.pSymmetric(horizontal: 15),
                  child: inventoryAsync.when(
                    data: (inventoryItems) =>
                        _buildInventoryContent(context, ref, inventoryItems),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        _buildErrorState(context, ref, error.toString()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryContent(
    BuildContext context,
    WidgetRef ref,
    List<InventoryItemOut> items,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.boxOpen,
              size: 64.s,
              color: AppColors.textGrey.withValues(alpha: 0.5),
            ),
            SizedBox(height: 20.s),
            Text(
              ref.t(LocalizationKeys.noItemsAvailable),
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 18.f,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.s),
            Text(
              'Buy items from the shop to see them here',
              style: TextStyle(
                color: AppColors.textGrey.withValues(alpha: 0.7),
                fontSize: 14.f,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with item count
        Padding(
          padding: ResponsiveUtils.pSymmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Items',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 18.f,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: ResponsiveUtils.pSymmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.angolaYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.angolaYellow.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${items.length} items',
                  style: TextStyle(
                    color: AppColors.angolaYellow,
                    fontSize: 12.f,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Inventory table
        Expanded(
          child: GlassContainer(
            borderRadius: 16,
            child: Column(
              children: [
                // Table header
                Container(
                  padding: ResponsiveUtils.pSymmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.angolaBlack.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.textGrey.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Item',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14.f,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            'Qty',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14.f,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            'Status',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14.f,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable inventory items
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: AppColors.textGrey.withValues(alpha: 0.2),
                    ),
                    itemBuilder: (context, index) =>
                        _buildInventoryItem(context, ref, items[index]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryItem(
    BuildContext context,
    WidgetRef ref,
    InventoryItemOut item,
  ) {
    final serverTime = ref.watch(currentServerTimeProvider);
    final bool isExpired =
        item.expiresAt != null && serverTime.isAfter(item.expiresAt!);
    final bool hasTimeRemaining =
        item.timeRemainingSeconds != null && item.timeRemainingSeconds! > 0;

    return Container(
      padding: ResponsiveUtils.pSymmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Item info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Item icon
                Container(
                  width: 40.s,
                  height: 40.s,
                  margin: EdgeInsets.only(right: 12.s),
                  decoration: BoxDecoration(
                    color: AppColors.angolaBlack.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.angolaYellow.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getIconForItemType(item.itemType, item.itemId),
                    size: 20.s,
                    color: isExpired
                        ? AppColors.textGrey.withValues(alpha: 0.5)
                        : AppColors.angolaYellow,
                  ),
                ),

                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          color: isExpired
                              ? AppColors.textGrey.withValues(alpha: 0.5)
                              : AppColors.textLight,
                          fontSize: 14.f,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.description.isNotEmpty) ...[
                        SizedBox(height: 2.s),
                        Text(
                          item.description,
                          style: TextStyle(
                            color: AppColors.textGrey.withValues(alpha: 0.7),
                            fontSize: 11.f,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quantity
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: ResponsiveUtils.pSymmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.angolaBlack.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.textGrey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13.f,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: Center(
              child: _buildItemStatus(item, isExpired, hasTimeRemaining),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemStatus(
    InventoryItemOut item,
    bool isExpired,
    bool hasTimeRemaining,
  ) {
    if (isExpired) {
      return Container(
        padding: ResponsiveUtils.pSymmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          'Expired',
          style: TextStyle(
            color: Colors.red,
            fontSize: 11.f,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (hasTimeRemaining && item.expiresAt != null) {
      final timeRemaining = _formatTimeRemaining(
        item.timeRemainingSeconds!.toInt(),
      );
      return Container(
        padding: ResponsiveUtils.pSymmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.angolaYellow.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: AppColors.angolaYellow.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          timeRemaining,
          style: TextStyle(
            color: AppColors.angolaYellow,
            fontSize: 11.f,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return Container(
        padding: ResponsiveUtils.pSymmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          'Active',
          style: TextStyle(
            color: Colors.green,
            fontSize: 11.f,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.triangleExclamation,
            size: 48.s,
            color: Colors.red.withValues(alpha: 0.7),
          ),
          SizedBox(height: 16.s),
          Text(
            'Failed to load inventory',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 18.f,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.s),
          Text(
            error,
            style: TextStyle(color: AppColors.textGrey, fontSize: 14.f),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.s),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(inventoryProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForItemType(String itemType, String itemId) {
    switch (itemType) {
      case 'BOOSTER':
        if (itemId.contains('speed')) return FontAwesomeIcons.rocket;
        if (itemId.contains('coin')) return FontAwesomeIcons.coins;
        if (itemId.contains('prestige')) return FontAwesomeIcons.trophy;
        if (itemId.contains('brain')) return FontAwesomeIcons.brain;
        if (itemId.contains('land')) return FontAwesomeIcons.mountain;
        return FontAwesomeIcons.bolt;
      case 'ACCESS_KEY':
        if (itemId.contains('bronze')) return FontAwesomeIcons.key;
        if (itemId.contains('silver')) return FontAwesomeIcons.key;
        if (itemId.contains('gold')) return FontAwesomeIcons.key;
        if (itemId.contains('platinum')) return FontAwesomeIcons.key;
        if (itemId.contains('permanent')) return FontAwesomeIcons.crown;
        return FontAwesomeIcons.key;
      case 'SPECIAL':
        return FontAwesomeIcons.wandMagicSparkles;
      case 'BUNDLE':
        return FontAwesomeIcons.box;
      default:
        return FontAwesomeIcons.gift;
    }
  }

  String _formatTimeRemaining(int totalSeconds) {
    if (totalSeconds <= 0) return 'Expired';

    final duration = Duration(seconds: totalSeconds);

    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
