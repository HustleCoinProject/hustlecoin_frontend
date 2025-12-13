// lib/widgets/info_popup.dart

import 'package:flutter/material.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';

/// A simple reusable info popup
class InfoPopup {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
  }) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 12,
          child: Container(
            padding: ResponsiveUtils.p(12),
            constraints: BoxConstraints(maxWidth: 350.s),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 16.s,
                    ),
                    SizedBox(width: 6.s),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 12.f,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 4.s),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 11.f,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20.s),
                  ],
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: ResponsiveUtils.p(8),
                      child: Icon(
                        Icons.close,
                        color: AppColors.textGrey,
                        size: 16.s,
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
}
