import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/features/notifications/widgets/notification_item.dart';
import 'package:hustlecoin/providers/notification_provider.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/features/payout/payout_history_screen.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh notifications when entering the screen to ensure up-to-date status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(notificationListProvider.notifier)
          .fetchNotifications(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final userState = ref.watch(userControllerProvider);
    final user = userState.value;
    final backgroundPath = user != null
        ? 'assets/images/${HustleUtils.getCurrentHustleKey(user.currentHustle)}.jpg'
        : 'assets/images/CEO.jpg';

    return Scaffold(
      backgroundColor: AppColors.angolaBlack,
      appBar: AppBar(
        backgroundColor: AppColors.angolaBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 20.f,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColors.angolaYellow),
            onPressed: () {
              ref.read(notificationListProvider.notifier).markAllRead();
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: ScreenBackground(
        imagePath: backgroundPath,
        child: SafeArea(
          child: notificationsAsync.when(
            data: (notifications) {
              if (notifications.isEmpty) {
                return Center(
                  child: Text(
                    'No notifications yet',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 16.f),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => ref
                    .read(notificationListProvider.notifier)
                    .fetchNotifications(refresh: true),
                color: AppColors.angolaYellow,
                backgroundColor: AppColors.angolaBlack,
                child: ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (ctx, i) => Divider(
                    color: AppColors.textGrey.withOpacity(0.1),
                    height: 1,
                  ),
                  itemBuilder: (ctx, i) {
                    final notification = notifications[i];
                    return NotificationItem(
                      notification: notification,
                      onTap: () {
                        if (!notification.isRead) {
                          ref
                              .read(notificationListProvider.notifier)
                              .logRead(notification.id);
                        }

                        // Navigation Logic based on metadata
                        // For now, allow simple closing or basic feedback

                        // p.s. The user mentioned: "should open notifications" - which implies viewing details.
                        // But the item itself shows message. Maybe if long message expand?
                        // Or navigate to related screen like Payout History.

                        if (notification.type == 'payout_status') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PayoutHistoryScreen(),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.angolaYellow),
            ),
            error: (err, stack) => Center(
              child: Text(
                'Failed to load notifications',
                style: TextStyle(color: AppColors.angolaRed),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
