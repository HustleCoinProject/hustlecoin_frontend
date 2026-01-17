import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/event.dart';
import 'package:hustlecoin/features/events/widgets/event_countdown.dart';
import 'package:intl/intl.dart';
import 'package:hustlecoin/providers/event_provider.dart';
import 'package:hustlecoin/providers/time_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_button.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/loading_indicator.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/widgets/screen_header.dart';
import 'package:hustlecoin/features/events/event_leaderboard_screen.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userControllerProvider);
    final eventsAsync = ref.watch(eventsListProvider);

    final user = userState.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null, // Handle appropriately if critical
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
                Expanded(
                  child: eventsAsync.when(
                    data: (events) =>
                        _buildEventsList(context, ref, events, user),
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (err, stack) => Center(
                      child: Text(
                        'Failed to load events',
                        style: TextStyle(color: AppColors.error),
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

  Widget _buildEventsList(
    BuildContext context,
    WidgetRef ref,
    List<Event> events,
    dynamic user,
  ) {
    if (events.isEmpty) {
      return Center(child: Text("No events available"));
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.s),
      itemCount: events.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.s),
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(context, ref, event, user);
      },
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    WidgetRef ref,
    Event event,
    dynamic user,
  ) {
    return GlassContainer(
      padding: EdgeInsets.all(16.s),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.name,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 18.f,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (event.isJoined)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.s, vertical: 4.s),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Text(
                    "JOINED",
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10.f,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.s),
          Text(
            event.description,
            style: TextStyle(color: AppColors.textGrey, fontSize: 13.f),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.s),
          // Compact info row with stats and countdown
          Row(
            children: [
              // Stats
              FaIcon(
                FontAwesomeIcons.users,
                size: 13.s,
                color: AppColors.textGrey,
              ),
              SizedBox(width: 4.s),
              Text(
                "${event.participantsCount}",
                style: TextStyle(color: AppColors.textGrey, fontSize: 12.f),
              ),
              SizedBox(width: 12.s),
              FaIcon(
                FontAwesomeIcons.trophy,
                size: 13.s,
                color: AppColors.angolaYellow,
              ),
              SizedBox(width: 4.s),
              Text(
                "${event.entryFee} HC",
                style: TextStyle(color: AppColors.textGrey, fontSize: 12.f),
              ),
              Spacer(),
              // Compact countdown/timer
              Consumer(
                builder: (context, ref, child) {
                  final serverTime = ref.watch(serverTimeProvider.notifier).currentServerTime;
                  if (serverTime.isBefore(event.endTime)) {
                    return _buildCompactTimer(
                      targetDate: serverTime.isBefore(event.startTime)
                          ? event.startTime
                          : event.endTime,
                      isStarting: serverTime.isBefore(event.startTime),
                      ref: ref,
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
          SizedBox(height: 10.s),
          // Compact dates row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.play,
                      size: 10.s,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 4.s),
                    Flexible(
                      child: Text(
                        DateFormat('MMM d, h:mm a').format(event.startTime.toLocal()),
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 11.f,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.s),
              Expanded(
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.flagCheckered,
                      size: 10.s,
                      color: AppColors.angolaRed,
                    ),
                    SizedBox(width: 4.s),
                    Flexible(
                      child: Text(
                        DateFormat('MMM d, h:mm a').format(event.endTime.toLocal()),
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 11.f,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.s),
          // Actions
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EventLeaderboardScreen(event: event),
                      ),
                    );
                  },
                  label: "LEADERBOARD",
                  icon: FontAwesomeIcons.trophy,
                  isSecondary: true,
                ),
              ),
              if (!event.isJoined) ...[
                SizedBox(width: 12.s),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final joinState = ref.watch(joinEventControllerProvider);
                      final isLoading = joinState is AsyncLoading;

                      return GlassButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                // Confirm join
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: AppColors.backgroundDark,
                                    title: Text(
                                      "Join Event?",
                                      style: TextStyle(
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                    content: Text(
                                      "Entry fee is ${event.entryFee} HC. Do you want to join?",
                                      style: TextStyle(
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: Text(
                                          "JOIN",
                                          style: TextStyle(
                                            color: AppColors.angolaYellow,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await ref
                                      .read(
                                        joinEventControllerProvider.notifier,
                                      )
                                      .joinEvent(event.eventId);
                                }
                              },
                        label: "JOIN (${event.entryFee} HC)",
                        icon: FontAwesomeIcons.rightToBracket,
                        isPrimary: true,
                      );
                    },
                  ),
                ),
              ] else ...[
                SizedBox(width: 12.s),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.s,
                      horizontal: 8.s,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.textGrey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "POINTS: ${event.currentRankPoints}",
                        style: TextStyle(
                          color: AppColors.angolaYellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.f,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTimer({
    required DateTime targetDate,
    required bool isStarting,
    required WidgetRef ref,
  }) {
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
      builder: (context, snapshot) {
        final now = ref.read(serverTimeProvider.notifier).currentServerTime;
        final difference = targetDate.difference(now);
        
        if (difference.isNegative) {
          return SizedBox.shrink();
        }

        final days = difference.inDays;
        final hours = difference.inHours.remainder(24);
        final minutes = difference.inMinutes.remainder(60);

        String timeText;
        if (days > 0) {
          timeText = '${days}d ${hours}h';
        } else if (hours > 0) {
          timeText = '${hours}h ${minutes}m';
        } else {
          timeText = '${minutes}m';
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.s, vertical: 4.s),
          decoration: BoxDecoration(
            color: (isStarting ? AppColors.angolaYellow : AppColors.angolaRed)
                .withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: (isStarting ? AppColors.angolaYellow : AppColors.angolaRed)
                  .withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                isStarting ? FontAwesomeIcons.clock : FontAwesomeIcons.hourglass,
                size: 10.s,
                color: isStarting ? AppColors.angolaYellow : AppColors.angolaRed,
              ),
              SizedBox(width: 4.s),
              Text(
                timeText,
                style: TextStyle(
                  color: isStarting ? AppColors.angolaYellow : AppColors.angolaRed,
                  fontSize: 11.f,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
