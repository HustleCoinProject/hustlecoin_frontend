import 'package:flutter/material.dart';
import 'package:hustlecoin/data/models/notification.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: ResponsiveUtils.pSymmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.transparent
              : AppColors.angolaRed.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(
              color: AppColors.textGrey.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 4.s, right: 12.s),
              width: 8.s,
              height: 8.s,
              decoration: BoxDecoration(
                color: notification.isRead
                    ? Colors.transparent
                    : AppColors.angolaRed,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            fontSize: 14.f,
                          ),
                        ),
                      ),
                      Text(
                        '${notification.createdAt.day}/${notification.createdAt.month} ${notification.createdAt.hour}:${notification.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 10.f,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.s),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: AppColors.textGrey.withOpacity(0.9),
                      fontSize: 12.f,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
