import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/user.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/widgets/screen_header.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userControllerProvider);
    final user = userState.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );

    return ResponsiveBuilder(
      builder: (context) => Scaffold(
        body: ScreenBackground(
          imagePath:
              'assets/images/${user != null ? HustleUtils.getCurrentHustleKey(user.currentHustle) : "Taxi Driver"}.jpg',
          child: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: ref.t(LocalizationKeys.events).toUpperCase(),
                  showBackButton: true,
                ),
                Expanded(child: Center(child: _buildEmptyState(ref))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(WidgetRef ref) {
    return Padding(
      padding: ResponsiveUtils.pSymmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state icon
          Container(
            width: 120.s,
            height: 120.s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.textGrey.withValues(alpha: 0.3),
                  AppColors.textGrey.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.calendarXmark,
                size: 50.s,
                color: AppColors.textGrey.withValues(alpha: 0.6),
              ),
            ),
          ),
          SizedBox(height: 24.s),
          Text(
            ref.t(LocalizationKeys.noEventsYet),
            style: TextStyle(
              fontSize: 24.f,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.s),
          Text(
            ref.t(LocalizationKeys.eventsComingSoon),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.f,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
          SizedBox(height: 32.s),
          GlassContainer(
            borderRadius: 12,
            padding: ResponsiveUtils.pSymmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.clock,
                  size: 16.s,
                  color: AppColors.angolaYellow,
                ),
                SizedBox(width: 10.s),
                Text(
                  ref.t(LocalizationKeys.comingSoon),
                  style: TextStyle(
                    fontSize: 13.f,
                    fontWeight: FontWeight.w600,
                    color: AppColors.angolaYellow,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
