import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/data/models/leaderboard_entry.dart';
import 'package:hustlecoin/providers/leaderboard_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
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
  final String currentHustle;
  final IconData avatarIcon;

  LeaderboardEntryUI({
    required this.rank,
    required this.username,
    required this.score,
    required this.level,
    required this.currentHustle,
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
    final user = userState.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );

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
        currentHustle: HustleUtils.getCurrentHustleDisplayName(
          user.currentHustle,
        ),
      );
    } else {
      // User data isn't available yet, show a complete placeholder
      playerEntryUI = LeaderboardEntryUI(
        rank: 0,
        username: 'You',
        score: 0,
        level: 0,
        currentHustle: 'Unknown',
      );
    }

    return Scaffold(
      body: ScreenBackground(
        imagePath:
            'assets/images/${user != null ? HustleUtils.getCurrentHustleKey(user.currentHustle) : "Taxi Driver"}.jpg',
        child: SafeArea(
          child: Column(
            children: [
              ScreenHeader(title: ref.t(LocalizationKeys.leaderboard)),
              _buildInfoTicker(ref),
              _buildContent(leaderboardAsync, ref),
              _buildPlayerHighlight(playerEntryUI),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTicker(WidgetRef ref) {
    return _InfoTicker(
      resetText: ref.t(LocalizationKeys.leaderboardDisclaimer),
      rewardsText: ref.t(LocalizationKeys.top3Rewards),
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
              currentHustle: entry.value.currentHustle,
            );
          }).toList();

          return ListView.builder(
            padding: ResponsiveUtils.pSymmetric(
              horizontal: 15.0,
              vertical: 10.0,
            ),
            itemCount: leaderboardData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.s),
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
      margin: ResponsiveUtils.pLTRB(15, 0, 15, 15),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.angolaYellow, width: 2.s),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.glowYellow,
            blurRadius: 20.s,
            spreadRadius: -5.s,
            offset: Offset(0, -5.s),
          ),
        ],
      ),
      child: _buildRankItem(playerEntry, isPlayer: true),
    );
  }

  Widget _buildRankItem(LeaderboardEntryUI entry, {bool isPlayer = false}) {
    Color rankColor = AppColors.textGrey;
    Color borderColor = Colors.white.withOpacity(0.1);
    List<BoxShadow>? boxShadow;

    if (entry.rank == 1) {
      rankColor = AppColors.gold;
      borderColor = AppColors.gold;
      boxShadow = [
        BoxShadow(
          color: AppColors.gold.withOpacity(0.3),
          blurRadius: 10.s,
          spreadRadius: -2.s,
        ),
      ];
    } else if (entry.rank == 2) {
      rankColor = AppColors.silver;
      borderColor = AppColors.silver;
      boxShadow = [
        BoxShadow(
          color: AppColors.silver.withOpacity(0.2),
          blurRadius: 10.s,
          spreadRadius: -2.s,
        ),
      ];
    } else if (entry.rank == 3) {
      rankColor = AppColors.bronze;
      borderColor = AppColors.bronze;
      boxShadow = [
        BoxShadow(
          color: AppColors.bronze.withOpacity(0.2),
          blurRadius: 10.s,
          spreadRadius: -2.s,
        ),
      ];
    }

    if (isPlayer) {
      borderColor = AppColors.angolaYellow;
    }

    return GlassContainer(
      borderRadius: 8.r, // Sharper corners for challenge feel
      padding: ResponsiveUtils.pSymmetric(horizontal: 15, vertical: 12),
      border: Border.all(
        color: borderColor,
        width: isPlayer || entry.rank <= 3 ? 1.5.s : 1.s,
      ),
      boxShadow: boxShadow,
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40.s,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isPlayer
                      ? (entry.rank > 0 ? '${entry.rank}' : '---')
                      : '${entry.rank}',
                  style: TextStyle(
                    fontSize: 20.f,
                    fontWeight: FontWeight.w900, // Bolder
                    fontStyle: FontStyle.italic, // Dynamic feel
                    color: isPlayer ? AppColors.angolaYellow : rankColor,
                  ),
                ),
                if (!isPlayer && entry.rank == 1)
                  Padding(
                    padding: EdgeInsets.only(left: 4.s),
                    child: FaIcon(
                      FontAwesomeIcons.crown,
                      size: 14.s,
                      color: rankColor,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12.s),

          // Avatar Placeholder (Optional, keeps generic if no avatar system yet)
          Container(
            width: 35.s,
            height: 35.s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isPlayer
                    ? AppColors.angolaYellow
                    : rankColor.withOpacity(0.5),
                width: 1.5.s,
              ),
              gradient: LinearGradient(
                colors: [
                  (isPlayer ? AppColors.angolaYellow : rankColor).withOpacity(
                    0.2,
                  ),
                  (isPlayer ? AppColors.angolaYellow : rankColor).withOpacity(
                    0.05,
                  ),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              entry.avatarIcon,
              size: 16.s,
              color: isPlayer ? AppColors.angolaYellow : rankColor,
            ),
          ),

          SizedBox(width: 12.s),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.username,
                  style: TextStyle(
                    fontWeight: isPlayer ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 15.f,
                    color: isPlayer ? AppColors.angolaYellow : Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Level ${entry.level} • ${entry.currentHustle}',
                  style: TextStyle(
                    fontSize: 11.f,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Rank Points
          Container(
            padding: ResponsiveUtils.pSymmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.angolaYellow.withOpacity(0.3),
                width: 1.s,
              ),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.trophy,
                  color: AppColors.angolaYellow,
                  size: 12.s,
                ),
                SizedBox(width: 6.s),
                Text(
                  entry.score
                      .toString(), // formatNumber removed as it doesn't exist
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.f,
                    color: AppColors.angolaYellow,
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

class _InfoTicker extends StatefulWidget {
  final String resetText;
  final String rewardsText;

  const _InfoTicker({required this.resetText, required this.rewardsText});

  @override
  State<_InfoTicker> createState() => _InfoTickerState();
}

class _InfoTickerState extends State<_InfoTicker> {
  bool _showResetInfo = true;
  // late final java.util.Timer _timer; // Avoiding Timer naming conflict if dart:async is imported - removed unused

  @override
  void initState() {
    super.initState();
    // Start flipping every 4 seconds
    Future.delayed(Duration.zero, () {
      // Using a periodic timer from Dart's async library
      // Since we didn't import dart:async with prefix, and Timer is a common name
      // We will assume standard Timer import or use Future.delayed loop if preferred.
      // But standard Timer.periodic is best.
      // Let's rely on standard Timer usage, assuming imports are clean.
      _startTimer();
    });
  }

  void _startTimer() {
    // Simple recursive future delay to avoid import issues if any
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showResetInfo = !_showResetInfo;
        });
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine current text and icon based on state
    final text = _showResetInfo ? widget.resetText : widget.rewardsText;
    final icon = _showResetInfo
        ? FontAwesomeIcons.clock
        : FontAwesomeIcons.trophy;
    // Highlight rewards text more
    // Make text white with glow for "calming" look against background, or keep yellow but remove box
    // User requested "calming and not like a panel".
    // Let's use use text with shadow for legibility without the box.
    final color = _showResetInfo ? AppColors.angolaYellow : AppColors.gold;

    return Container(
      margin: ResponsiveUtils.pSymmetric(horizontal: 15.0),
      padding: ResponsiveUtils.pSymmetric(vertical: 8.0, horizontal: 12.0),
      // Removed BoxDecoration for cleaner look
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Row(
          key: ValueKey<bool>(_showResetInfo),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 14.s, // Slightly larger icon
              color: color,
            ),
            SizedBox(width: 8.s),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13.f, // Slightly larger text
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                  Shadow(color: color.withOpacity(0.5), blurRadius: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
