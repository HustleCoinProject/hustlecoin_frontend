import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/data/models/leaderboard_entry.dart';
import 'package:hustlecoin/providers/leaderboard_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/widgets/screen_header.dart';

// Local data model for a leaderboard entry UI
class LeaderboardEntryUI {
  final int rank;
  final String username;
  final int score;
  final int level;
  final IconData avatarIcon;

  LeaderboardEntryUI({
    required this.rank,
    required this.username,
    required this.score,
    required this.level,
    this.avatarIcon = FontAwesomeIcons.user,
  });
}

// --- Main Leaderboard Screen Widget ---

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get leaderboard and user data from providers
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final userState = ref.watch(userControllerProvider);
    final user = userState.value;

    // Determine the player's entry for the highlight bar at the bottom
    final LeaderboardEntryUI playerEntryUI;

    if (user != null) {
      // We have user data, so we can show their real score
      int rank = 0; // Default to 0 (unknown rank)
      // If the leaderboard data has loaded, try to find the user's rank
      if (leaderboardAsync.hasValue) {
        final entries = leaderboardAsync.value!;
        final userIndex = entries.indexWhere(
          (e) => e.username == user.username,
        );
        if (userIndex != -1) {
          rank = userIndex + 1;
        }
      }
      playerEntryUI = LeaderboardEntryUI(
        rank: rank,
        username: 'You',
        score: user.rankPoints,
        level: user.level,
      );
    } else {
      // User data isn't available yet, show a complete placeholder
      playerEntryUI = LeaderboardEntryUI(
        rank: 0,
        username: 'You',
        score: 0,
        level: 0,
      );
    }

    return Scaffold(
      body: ScreenBackground(
        imagePath:
            'assets/images/${user != null ? HustleUtils.getCurrentHustleKey(user.currentHustle) : "Taxi Driver"}.png',
        child: SafeArea(
          child: Column(
            children: [
              ScreenHeader(title: ref.t(LocalizationKeys.leaderboard)),
              _buildContent(leaderboardAsync, ref),
              _buildPlayerHighlight(playerEntryUI),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    AsyncValue<List<LeaderboardEntry>> leaderboardAsync,
    WidgetRef ref,
  ) {
    return Expanded(
      child: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            '${ref.t(LocalizationKeys.failedToLoadLeaderboard)}: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (leaderboardEntries) {
          final leaderboardData = leaderboardEntries.asMap().entries.map((
            entry,
          ) {
            // Convert backend LeaderboardEntry to UI LeaderboardEntryUI
            return LeaderboardEntryUI(
              rank: entry.key + 1, // Index + 1 for rank
              username: entry.value.username,
              score: entry.value.rankPoints,
              level: entry.value.level,
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 15.0,
            ),
            itemCount: leaderboardData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _buildRankItem(leaderboardData[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPlayerHighlight(LeaderboardEntryUI playerEntry) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      decoration: BoxDecoration(
        border: const Border(
          top: BorderSide(color: AppColors.angolaYellow, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.glowYellow,
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: _buildRankItem(playerEntry, isPlayer: true),
    );
  }

  Widget _buildRankItem(LeaderboardEntryUI entry, {bool isPlayer = false}) {
    Color rankColor = AppColors.textGrey;
    Color borderColor = Colors.transparent;
    List<BoxShadow>? boxShadow;

    if (entry.rank == 1) {
      rankColor = AppColors.gold;
      borderColor = AppColors.gold;
      boxShadow = [
        BoxShadow(color: AppColors.gold, blurRadius: 15, spreadRadius: -3),
      ];
    } else if (entry.rank == 2) {
      rankColor = AppColors.silver;
      borderColor = AppColors.silver;
      boxShadow = [
        BoxShadow(color: AppColors.silver, blurRadius: 15, spreadRadius: -3),
      ];
    } else if (entry.rank == 3) {
      rankColor = AppColors.bronze;
      borderColor = AppColors.bronze;
      boxShadow = [
        BoxShadow(color: AppColors.bronze, blurRadius: 15, spreadRadius: -3),
      ];
    }

    return GlassContainer(
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      border: Border.all(
        color: isPlayer ? AppColors.angolaYellow : borderColor,
        width: 2,
      ),
      boxShadow: boxShadow,
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isPlayer
                      ? (entry.rank > 0 ? '${entry.rank}' : '---')
                      : '${entry.rank}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isPlayer ? AppColors.angolaYellow : rankColor,
                  ),
                ),
                if (!isPlayer && entry.rank == 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: FaIcon(
                      FontAwesomeIcons.crown,
                      size: 14,
                      color: rankColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // User Info
          Text(
            entry.username,
            style: TextStyle(
              fontWeight: isPlayer ? FontWeight.w700 : FontWeight.w600,
              color: isPlayer ? AppColors.angolaYellow : null,
            ),
          ),
          const Spacer(),
          // Rank Points
          FaIcon(
            FontAwesomeIcons.trophy,
            color: AppColors.angolaYellow,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            entry.score.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isPlayer ? AppColors.angolaYellow : null,
            ),
          ),
        ],
      ),
    );
  }
}
