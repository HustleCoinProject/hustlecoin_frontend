import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/services/remote_config_service.dart';
import 'package:hustlecoin/features/notifications/notification_screen.dart';
import 'package:hustlecoin/providers/notification_provider.dart';
import 'game_avatar_widget.dart';

class TopBar extends ConsumerWidget {
  final void Function()
  onToggleLanguage; // Kept for interface compatibility but unused in UI
  final GlobalKey? hcBalanceKey;

  const TopBar({super.key, required this.onToggleLanguage, this.hcBalanceKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider).value;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: ResponsiveUtils.pSymmetric(horizontal: 15.0, vertical: 10.0),
      child: SizedBox(
        height:
            68.s, // Ensure height for the tallest element (GameAvatarWidget)
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GlassContainer(
                key: hcBalanceKey,
                borderRadius: 12,
                child: Padding(
                  padding: ResponsiveUtils.p(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38.s,
                        height: 38.s,
                        margin: EdgeInsets.only(right: 8.s),
                        decoration: BoxDecoration(
                          color: AppColors.angolaRed,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.glowRed,
                              blurRadius: 8,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Icon(
                          FontAwesomeIcons.star,
                          size: 18.s,
                          color: AppColors.textLight,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${user.hcBalance} HC',
                            style: TextStyle(
                              fontSize: 16.f,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          Builder(
                            builder: (context) {
                              final rate = RemoteConfigService.instance
                                  .getHcToKzRate();
                              // Calculate Kz - user.hcBalance (int) / rate (double)
                              // floor() used to match previous behavior
                              final kzBalance = (user.hcBalance / rate).floor();
                              return Text(
                                '≈ Kz $kzBalance', // Using calculated local value
                                style: TextStyle(
                                  fontSize: 12.f,
                                  color: AppColors.textGrey,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(width: 12.s),
                    ],
                  ),
                ),
              ),
            ),

            const GameAvatarWidget(),

            Align(
              alignment: Alignment.centerRight,
              child: PressableScaleWidget(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
                child: GlassContainer(
                  borderRadius: 12,
                  child: Padding(
                    padding: ResponsiveUtils.p(12),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          FontAwesomeIcons.bell,
                          size: 20.s,
                          color: AppColors.textLight,
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final unreadCount = ref.watch(
                              unreadNotificationCountProvider,
                            );
                            if (unreadCount == 0)
                              return const SizedBox.shrink();
                            return Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 8.s,
                                height: 8.s,
                                decoration: const BoxDecoration(
                                  color: AppColors.angolaRed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
