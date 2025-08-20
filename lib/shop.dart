import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/state/all_states.dart';
import 'package:hustlecoin/widgets/banner_ad_widget.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'app_colors.dart';

// Provider to track loading state for each shop item
final itemPurchasingProvider = StateProvider.autoDispose.family<bool, String>(
  (ref, itemId) => false,
);

// --- Reusable Helper Widgets ---

// High-performance "smoky glass" container without blur
class _GlassEffectContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const _GlassEffectContainer({
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: borderRadius,
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

// --- Main Shop Screen Widget ---

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
    final user = userState.value;

    // Get the shop items from the provider
    final shopItemsAsync = ref.watch(shopItemsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/${user != null ? HustleUtils.getCurrentHustleKey(user.currentHustle) : "Taxi Driver"}.png',
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
            child: Column(
              children: [
                _buildHeader(context, user),
                // Banner ad
                const BannerAdWidget(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                ),
                // Display the title based on filter
                _buildShopTitle(context),
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

  // Build the shop title
  Widget _buildShopTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        _getShopTitle(ref),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: [
          PressableWidget(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const _GlassEffectContainer(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: SizedBox(
                width: 54,
                height: 54,
                child: Icon(FontAwesomeIcons.arrowLeft, size: 20),
              ),
            ),
          ),
          const Spacer(),
          _GlassEffectContainer(
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.angolaRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.star,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.hcBalance ?? 0} HC',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '≈ Kz ${user?.kzBalance ?? 0}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<ShopItem> items,
  ) {
    return Expanded(
      child: items.isEmpty
          ? const Center(
              child: Text(
                'No items available',
                style: TextStyle(color: AppColors.textGrey, fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(15.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
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
    return _GlassEffectContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(16, 16, 16, 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconForItemType(item.itemType, item.itemId),
              size: 40,
              color: AppColors.angolaYellow,
            ),
          ),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
          ),
          const SizedBox(height: 15),
          // Use InkWell instead of GestureDetector for visual feedback with ripple effect
          InkWell(
            borderRadius: BorderRadius.circular(10),
            splashColor: Colors.white.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.1),
            onTap: isPurchasing
                ? null
                : () {
                    // Set purchase in progress state IMMEDIATELY
                    ref
                            .read(itemPurchasingProvider(item.itemId).notifier)
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
            // Using Material for better ink effects and feedback
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: isPurchasing
                        ? [
                            AppColors.angolaYellow.withOpacity(0.5),
                            AppColors.angolaRed.withOpacity(0.5),
                          ]
                        : [AppColors.angolaYellow, AppColors.angolaRed],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isPurchasing)
                        // Show a small loading indicator when purchasing
                        Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.only(right: 8),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        const FaIcon(
                          FontAwesomeIcons.coins,
                          size: 14,
                          color: Colors.white,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.price} HC',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
