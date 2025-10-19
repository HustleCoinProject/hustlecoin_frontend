import 'package:flutter/foundation.dart';

@immutable
class LeaderboardEntry {
  final String username;
  final int hcBalance;
  final int level;

  const LeaderboardEntry({
    required this.username,
    required this.hcBalance,
    required this.level,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      username: json['username'],
      hcBalance: json['hc_balance'],
      level: json['level'],
    );
  }
}
