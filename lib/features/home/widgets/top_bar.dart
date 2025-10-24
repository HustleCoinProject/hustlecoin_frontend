import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/user.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';

class TopBar extends ConsumerWidget {
  final User user;
  final Future<void> Function(String) onToggleLanguage;

  const TopBar({super.key, required this.user, required this.onToggleLanguage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: ResponsiveUtils.pSymmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassContainer(
            borderRadius: 12,
            child: Padding(
              padding: ResponsiveUtils.p(8.0),
              child: Row(
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
                    children: [
                      Text(
                        '${user.hcBalance} HC',
                        style: TextStyle(
                          fontSize: 16.f,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '≈ Kz ${user.kzBalance}',
                        style: TextStyle(
                          fontSize: 12.f,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12.s),
                ],
              ),
            ),
          ),
          Container(
            width: 54.s,
            height: 54.s,
            padding: ResponsiveUtils.p(3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.angolaYellow, AppColors.angolaRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: GlassContainer(
              borderRadius: 13,
              child: Icon(FontAwesomeIcons.user, size: 28.s),
            ),
          ),
          PressableScaleWidget(
            onTap: () => onToggleLanguage(user.language),
            soundType:
                SoundType.switchSound, // Use switch sound for language toggle
            child: GlassContainer(
              borderRadius: 12,
              child: Padding(
                padding: ResponsiveUtils.pSymmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: ResponsiveUtils.pSymmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: user.language.toUpperCase() == 'EN'
                            ? AppColors.angolaYellow
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'EN',
                        style: TextStyle(
                          color: user.language.toUpperCase() == 'EN'
                              ? AppColors.angolaBlack
                              : AppColors.textGrey,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.f,
                        ),
                      ),
                    ),
                    Container(
                      padding: ResponsiveUtils.pSymmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: user.language.toUpperCase() == 'PT'
                            ? AppColors.angolaYellow
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'PT',
                        style: TextStyle(
                          color: user.language.toUpperCase() == 'PT'
                              ? AppColors.angolaBlack
                              : AppColors.textGrey,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.f,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
