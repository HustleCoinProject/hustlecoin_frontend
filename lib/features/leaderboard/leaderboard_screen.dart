import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/data/models/leaderboard_entry.dart';
import 'package:hustlecoin/providers/leaderboard_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/theme/app_colors.dart';

// --- Reusable Helper Widgets ---

// High-performance "smoky glass" container without blur
class _GlassEffectContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const _GlassEffectContainer({
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.padding = EdgeInsets.zero,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: borderRadius,
        border: border ?? Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow:
            boxShadow ??
            [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
      ),
      child: child,
    );
  }
}

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
  LeaderboardScreen({super.key});

  // Placeholder for the current player with dashes
  final LeaderboardEntryUI playerEntry = LeaderboardEntryUI(
    rank: 0,
    username: 'You',
    score: 0,
    level: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get leaderboard data from provider
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final userState = ref.watch(userControllerProvider);
    final user = userState.value;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/${user != null ? HustleUtils.getCurrentHustleKey(user.currentHustle) : "Taxi Driver"}.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                const Color(0xFF101010).withOpacity(0.4),
                const Color(0xFF101010).withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, ref),
                _buildContent(leaderboardAsync, ref),
                _buildPlayerHighlight(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const _GlassEffectContainer(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: SizedBox(
                width: 54,
                height: 54,
                child: Icon(FontAwesomeIcons.arrowLeft, size: 20),
              ),
            ),
          ),
          Text(
            ref.t(LocalizationKeys.leaderboard),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
            ),
          ),
          const SizedBox(width: 54), // Placeholder to keep title centered
        ],
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
              score: entry.value.hcBalance,
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

  Widget _buildPlayerHighlight() {
    // Display player with dashes since the server doesn't provide this information
    final playerEntryWithDashes = LeaderboardEntryUI(
      rank: 0,
      username: 'You',
      score: 0,
      level: 0,
    );

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
      child: _buildRankItem(playerEntryWithDashes, isPlayer: true),
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

    return _GlassEffectContainer(
      borderRadius: BorderRadius.circular(12),
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
                  isPlayer ? '---' : '${entry.rank}',
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
          // Coin Balance
          FaIcon(
            FontAwesomeIcons.coins,
            color: AppColors.angolaYellow,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isPlayer ? '---' : entry.score.toString(),
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
