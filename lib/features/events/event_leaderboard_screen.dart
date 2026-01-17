import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/event.dart';
import 'package:hustlecoin/providers/event_provider.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/loading_indicator.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/widgets/screen_header.dart';

class EventLeaderboardScreen extends ConsumerWidget {
  final Event event;

  const EventLeaderboardScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(eventLeaderboardProvider(event.eventId));

    return Scaffold(
      body: ScreenBackground(
        imagePath: 'assets/images/Hustle Legend.jpg',
        child: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: event.name.toUpperCase(),
                showBackButton: true,
              ),
              Expanded(
                child: leaderboardAsync.when(
                  data: (entries) => _buildLeaderboardList(context, entries),
                  loading: () => const Center(child: LoadingIndicator()),
                  error: (err, stack) => Center(
                    child: Text(
                      'Error loading leaderboard',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(
    BuildContext context,
    List<EventLeaderboardEntry> entries,
  ) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No participants yet!',
          style: TextStyle(color: AppColors.textGrey, fontSize: 16.f),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.s),
      itemCount: entries.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.s),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final rank = index + 1;

        return GlassContainer(
          padding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 12.s),
          borderRadius: 12,
          child: Row(
            children: [
              _buildRankBadge(rank),
              SizedBox(width: 12.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.username,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.f,
                      ),
                    ),
                    Text(
                      entry.currentHustle,
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12.f,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.rankPoints}',
                    style: TextStyle(
                      color: AppColors.angolaYellow,
                      fontWeight: FontWeight.w800,
                      fontSize: 18.f,
                    ),
                  ),
                  Text(
                    'PTS',
                    style: TextStyle(
                      color: AppColors.angolaYellow.withValues(alpha: 0.6),
                      fontSize: 10.f,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    if (rank == 1)
      badgeColor = const Color(0xFFFFD700); // Gold
    else if (rank == 2)
      badgeColor = const Color(0xFFC0C0C0); // Silver
    else if (rank == 3)
      badgeColor = const Color(0xFFCD7F32); // Bronze
    else
      badgeColor = AppColors.textGrey;

    return Container(
      width: 30.s,
      height: 30.s,
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: badgeColor, width: 2),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            color: badgeColor,
            fontWeight: FontWeight.bold,
            fontSize: 14.f,
          ),
        ),
      ),
    );
  }
}
