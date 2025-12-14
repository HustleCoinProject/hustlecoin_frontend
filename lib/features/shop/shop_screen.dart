import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/shop_item.dart';
import 'package:hustlecoin/providers/game_data_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/widgets/banner_ad_widget.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/primary_action_button.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/widgets/screen_header.dart';
import 'package:hustlecoin/widgets/info_popup.dart';

// Provider to track loading state for each shop item
final itemPurchasingProvider = StateProvider.autoDispose.family<bool, String>(
  (ref, itemId) => false,
);

class ShopScreen extends ConsumerStatefulWidget {
  final String? itemTypeFilter;
  final List<String>? excludeTypes;

  // Constructor that accepts optional itemTypeFilter and excludeTypes
  const ShopScreen({super.key, this.itemTypeFilter, this.excludeTypes});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    // Get the user data to display the HC balance
    final userState = ref.watch(userControllerProvider);
    final user = userState.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );

    // Get the shop items from the provider
    final shopItemsAsync = ref.watch(shopItemsProvider);

    return ResponsiveBuilder(
      builder: (context) => Scaffold(
        body: ScreenBackground(
          imagePath:
              'assets/images/${user != null ? HustleUtils.getCurrentHustleKey(user.currentHustle) : "Taxi Driver"}.jpg',
          child: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: _getShopTitle(ref),
                  trailingWidget: GlassContainer(
                    borderRadius: 12.r,
                    padding: ResponsiveUtils.p(8),
                    child: Row(
                      children: [
                        Container(
                          width: 38.s,
                          height: 38.s,
                          margin: EdgeInsets.only(right: 8.s),
                          decoration: BoxDecoration(
                            color: AppColors.angolaRed,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            FontAwesomeIcons.star,
                            size: 18.s,
                            color: AppColors.textLight,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user?.hcBalance ?? 0} HC',
                              style: TextStyle(
                                fontSize: 14.f,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '≈ Kz ${user?.kzBalance ?? 0}',
                              style: TextStyle(
                                fontSize: 11.f,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Banner ad
                BannerAdWidget(
                  margin: ResponsiveUtils.pSymmetric(horizontal: 15, vertical: 5),
                ),
                // Show loading indicator or shop items
                shopItemsAsync.when(
                  data: (shopItems) {
                    List<ShopItem> filteredItems = shopItems;

                    // Filter by item type if specified
                    if (widget.itemTypeFilter != null) {
                      filteredItems = shopItems
                          .where(
                            (item) => item.itemType == widget.itemTypeFilter,
                          )
                          .toList();
                    }

                    // Exclude specified item types if provided
                    if (widget.excludeTypes != null &&
                        widget.excludeTypes!.isNotEmpty) {
                      filteredItems = filteredItems
                          .where(
                            (item) =>
                                !widget.excludeTypes!.contains(item.itemType),
                          )
                          .toList();
                    }
                    return _buildContent(context, ref, filteredItems);
                  },
                  loading: () => const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, st) => Expanded(
                    child: Center(
                      child: Text(
                        'Failed to load shop items',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
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

  // Get the appropriate title based on filter
  String _getShopTitle(WidgetRef ref) {
    if (widget.itemTypeFilter == 'BOOSTER') {
      return ref.t(LocalizationKeys.boosters);
    } else if (widget.itemTypeFilter == 'ACCESS_KEY') {
      return ref.t(LocalizationKeys.keys);
    }
    return ref.t(LocalizationKeys.shop);
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<ShopItem> items,
  ) {
    return Expanded(
      child: items.isEmpty
          ? Center(
              child: Text(
                'No items available',
                style: TextStyle(color: AppColors.textGrey, fontSize: 16.f),
              ),
            )
          : GridView.builder(
              padding: ResponsiveUtils.p(15.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15.s,
                mainAxisSpacing: 15.s,
                childAspectRatio: 0.75, // Adjust this ratio to fit content
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildProductCard(context, ref, items[index]);
              },
            ),
    );
  }

  // Get appropriate icon for item type
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

  Widget _buildProductCard(BuildContext context, WidgetRef ref, ShopItem item) {
    // Watch the purchase state for this specific item
    final isPurchasing = ref.watch(itemPurchasingProvider(item.itemId));

    final user = ref.watch(userControllerProvider).value;
    final userBalance = user?.hcBalance ?? 0;
    final bool canAfford = userBalance >= item.price;

    return GlassContainer(
      borderRadius: 16.r,
      padding: ResponsiveUtils.p(15),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Container(
                width: 80.s,
                height: 80.s,
                margin: EdgeInsets.only(bottom: 10.s),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(16, 16, 16, 0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _getIconForItemType(item.itemType, item.itemId),
              size: 40.s,
              color: AppColors.angolaYellow,
            ),
          ),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.f,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
          SizedBox(height: 5.s),
          Expanded(
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.f, color: AppColors.textGrey),
            ),
          ),
          SizedBox(height: 15.s),

          SizedBox(
            width: double.infinity,
            child: PrimaryActionButton(
              text: '${item.price} HC',
              isLoading: isPurchasing,
              padding: ResponsiveUtils.pSymmetric(
                vertical: 12,
              ), // Override padding to match original
              onTap: (isPurchasing || !canAfford)
                  ? null
                  : () {
                      // Set purchase in progress state IMMEDIATELY
                      ref
                              .read(
                                itemPurchasingProvider(item.itemId).notifier,
                              )
                              .state =
                          true;

                      // Use Future.microtask to ensure UI updates before starting API call
                      Future.microtask(() async {
                        try {
                          // Purchase the item with quantity = 1
                          await ref
                              .read(userControllerProvider.notifier)
                              .purchaseItem(item.itemId);

                          // Show success message
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Successfully purchased ${item.name}!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          // Show error message
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to purchase: ${e.toString()}',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          // Reset purchase in progress state
                          if (context.mounted) {
                            ref
                                    .read(
                                      itemPurchasingProvider(
                                        item.itemId,
                                      ).notifier,
                                    )
                                    .state =
                                false;
                          }
                        }
                      });
                    },
            ),
          ),            ],
          ),
          // Info icon in top-right corner
          Positioned(
            top: -10,
            right: -10,
            child: GestureDetector(
              onTap: () {
                InfoPopup.show(
                  context: context,
                  title: item.name,
                  description: item.description,
                );
              },
              child: Container(
                padding: ResponsiveUtils.p(6),
                decoration: BoxDecoration(
                  color: AppColors.textGrey.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline,
                  color: const Color(0xFF7B94D1),
                  size: 16.s,
                ),
              ),
            ),
          ),        ],
      ),
    );
  }
}
