import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'app_colors.dart'; // Assuming you have this file from previous steps

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

// Data model for a leaderboard entry
class LeaderboardEntry {
  final int rank;
  final String username;
  final int score;
  final IconData avatarIcon;

  LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.score,
    this.avatarIcon = FontAwesomeIcons.user,
  });
}

// --- Main Leaderboard Screen Widget ---

class LeaderboardScreen extends StatelessWidget {
  LeaderboardScreen({super.key});

  // Dummy data for the leaderboard list
  final List<LeaderboardEntry> leaderboardData = [
    LeaderboardEntry(rank: 1, username: 'HustleKing', score: 98450),
    LeaderboardEntry(rank: 2, username: 'CoinMaster', score: 95210),
    LeaderboardEntry(rank: 3, username: 'AngolaRider', score: 91880),
    LeaderboardEntry(rank: 4, username: 'UrbanDriver', score: 88500),
    LeaderboardEntry(rank: 5, username: 'StreetSmart', score: 85120),
    LeaderboardEntry(rank: 6, username: 'LuandaLion', score: 82990),
    LeaderboardEntry(rank: 7, username: 'MidnightHustler', score: 79430),
    LeaderboardEntry(rank: 8, username: 'KwanzaFlow', score: 75600),
    LeaderboardEntry(rank: 9, username: 'CitySlicker', score: 72150),
    LeaderboardEntry(rank: 10, username: 'TheVendor', score: 68900),
    LeaderboardEntry(rank: 11, username: 'RhythmRider', score: 65400),
    LeaderboardEntry(rank: 12, username: 'AsphaltAce', score: 62300),
  ];

  // Dummy data for the current player
  final LeaderboardEntry playerEntry = LeaderboardEntry(
    rank: 142,
    username: 'You',
    score: 12507,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Taxi Driver.png'),
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
                _buildHeader(context),
                _buildContent(),
                _buildPlayerHighlight(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          const Text(
            'Leaderboard',
            style: TextStyle(
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

  Widget _buildContent() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
        itemCount: leaderboardData.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _buildRankItem(leaderboardData[index]),
          );
        },
      ),
    );
  }

  Widget _buildPlayerHighlight() {
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
      child: _buildRankItem(playerEntry),
    );
  }

  Widget _buildRankItem(LeaderboardEntry entry) {
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
      border: Border.all(color: borderColor, width: 2),
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
                  '${entry.rank}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: rankColor,
                  ),
                ),
                if (entry.rank == 1)
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(16, 16, 16, 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(entry.avatarIcon, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            entry.username,
            style: const TextStyle(fontWeight: FontWeight.w600),
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
            entry.score.toString(),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
