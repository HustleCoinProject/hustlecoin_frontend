// lib/widgets/upgrades_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/features/shop/shop_screen.dart';
import 'package:hustlecoin/features/inventory/inventory_screen.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/ad_helper.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';

class UpgradesSection extends ConsumerWidget {
  const UpgradesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: ResponsiveUtils.pLTRB(15, 10, 15, 10),
      child: ClipRect(
        child: Row(
          children: [
            _upgradeItem(
              context: context,
              ref: ref,
              icon: FontAwesomeIcons.boxes,
              label: ref.t(LocalizationKeys.inventory),
              onTap: () {
                AdHelper.showInterstitialOnNavigation();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InventoryScreen()),
                );
              },
            ),
            SizedBox(width: 8.s),
            _upgradeItem(
              context: context,
              ref: ref,
              icon: FontAwesomeIcons.rocket,
              label: ref.t(LocalizationKeys.boosts),
              onTap: () {
                AdHelper.showInterstitialOnNavigation();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ShopScreen(itemTypeFilter: 'BOOSTER'),
                  ),
                );
              },
            ),
            SizedBox(width: 8.s),
            _upgradeItem(
              context: context,
              ref: ref,
              icon: FontAwesomeIcons.key,
              label: ref.t(LocalizationKeys.keys),
              onTap: () {
                AdHelper.showInterstitialOnNavigation();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const ShopScreen(itemTypeFilter: 'ACCESS_KEY'),
                  ),
                );
              },
            ),
            SizedBox(width: 8.s),
            _upgradeItem(
              context: context,
              ref: ref,
              icon: FontAwesomeIcons.store,
              label: ref.t(LocalizationKeys.shop),
              isShop: true,
              onTap: () {
                AdHelper.showInterstitialOnNavigation();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ShopScreen(
                      excludeTypes: ["ACCESS_KEY", "BOOSTER"],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _upgradeItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    bool isShop = false,
    VoidCallback? onTap,
  }) {
    Widget content;
    if (isShop) {
      content = Container(
        height: 65.s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: const LinearGradient(
            colors: [AppColors.angolaYellow, AppColors.angolaRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.glowRed,
              blurRadius: 20,
              spreadRadius: -5,
            ),
          ],
        ),
        child: _upgradeItemContent(icon, label, AppColors.textLight),
      );
    } else {
      content = GlassContainer(
        borderRadius: 12,
        child: SizedBox(
          height: 65.s,
          child: _upgradeItemContent(icon, label, AppColors.textGrey),
        ),
      );
    }
    return Expanded(
      child: PressableScaleWidget(onTap: onTap, child: content),
    );
  }

  Widget _upgradeItemContent(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(icon, size: 22.s, color: color),
        SizedBox(height: 4.s),
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.f,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
