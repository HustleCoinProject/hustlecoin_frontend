import 'package:flutter/foundation.dart';

@immutable
class LeaderboardEntry {
  final String username;
  final int rankPoints;
  final int level;
  final int hcBalance; // Still included for reference

  const LeaderboardEntry({
    required this.username,
    required this.rankPoints,
    required this.level,
    required this.hcBalance,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      username: json['username'],
      rankPoints: json['rank_points'] ?? 0,
      level: json['level'] ?? 0,
      hcBalance: json['hc_balance'] ?? 0,
    );
  }
}
