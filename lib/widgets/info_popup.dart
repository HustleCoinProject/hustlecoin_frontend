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
          borderRadius: 0,
          child: Container(
            padding: ResponsiveUtils.p(20),
            constraints: BoxConstraints(maxWidth: 380.s),
            decoration: BoxDecoration(
              color: AppColors.glassBg,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.angolaYellow,
                      size: 20.s,
                    ),
                    SizedBox(width: 12.s),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14.f,
                              fontWeight: FontWeight.bold,
                              color: AppColors.angolaYellow,
                            ),
                          ),
                          SizedBox(height: 8.s),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 12.f,
                              color: AppColors.textLight,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 24.s),
                  ],
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: ResponsiveUtils.p(8),
                      decoration: BoxDecoration(
                        color: AppColors.angolaRed.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColors.textLight,
                        size: 18.s,
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
