import 'package:flutter/foundation.dart';

@immutable
class User {
  final String id;
  final String username;
  final String email;
  final int hcBalance;
  final int level;
  final dynamic
  currentHustle; // Can be String (old format) or Map<String, String> (new format)
  final DateTime levelEntryDate;
  final int hcEarnedInLevel;
  final String language;
  final Map<String, DateTime> taskCooldowns;
  final int dailyStreak;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.hcBalance,
    required this.level,
    required this.currentHustle,
    required this.levelEntryDate,
    required this.hcEarnedInLevel,
    required this.language,
    required this.taskCooldowns,
    required this.dailyStreak,
    required this.createdAt,
  });

  // A factory constructor for creating a new User instance from a map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      hcBalance: json['hc_balance'],
      level: json['level'],
      currentHustle: json['current_hustle'],
      levelEntryDate: DateTime.parse(json['level_entry_date']),
      hcEarnedInLevel: json['hc_earned_in_level'],
      language: json['language'],
      taskCooldowns: (json['task_cooldowns'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, DateTime.parse(value)),
      ),
      dailyStreak: json['daily_streak'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Visual-only Kwanza balance
  int get kzBalance => (hcBalance / 8).floor();
}
