import 'package:flutter/foundation.dart';
import 'pending_reward.dart';

@immutable
class User {
  final String id;
  final String username;
  final String email;
  final int hcBalance;
  final int rankPoints;
  final int level;
  final dynamic
  currentHustle; // Can be String (old format) or Map<String, String> (new format)
  final DateTime levelEntryDate;
  final int hcEarnedInLevel;
  final String language;
  final Map<String, DateTime> taskCooldowns;
  final int dailyStreak;
  final DateTime createdAt;
  final int dailyTapEarnings;
  final DateTime? lastTapResetDate;

  // Payout-related fields
  final String? phoneNumber;
  final String? fullName;
  final String? nationalId;
  final String? cryptoWalletAddress;
  final String? cryptoNetwork;

  // Pending Rewards
  final List<PendingReward> pendingRewards;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.hcBalance,
    required this.rankPoints,
    required this.level,
    required this.currentHustle,
    required this.levelEntryDate,
    required this.hcEarnedInLevel,
    required this.language,
    required this.taskCooldowns,
    required this.dailyStreak,
    required this.createdAt,
    required this.dailyTapEarnings,
    this.lastTapResetDate,
    this.phoneNumber,
    this.fullName,
    this.nationalId,
    this.cryptoWalletAddress,
    this.cryptoNetwork,
    this.pendingRewards = const [],
  });

  // A factory constructor for creating a new User instance from a map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      hcBalance: json['hc_balance'],
      rankPoints: json['rank_points'] ?? 0,
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
      dailyTapEarnings: json['daily_tap_earnings'] ?? 0,
      lastTapResetDate: json['last_tap_reset_date'] != null
          ? DateTime.parse(json['last_tap_reset_date'])
          : null,
      phoneNumber: json['phone_number'],
      fullName: json['full_name'],
      nationalId: json['national_id'],
      cryptoWalletAddress: json['crypto_wallet_address'],
      cryptoNetwork: json['crypto_network'],
      pendingRewards: json['pending_rewards'] != null
          ? (json['pending_rewards'] as List)
                .map((r) => PendingReward.fromJson(r))
                .toList()
          : [],
    );
  }

  // Create a copy of this User with updated fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    int? hcBalance,
    int? rankPoints,
    int? level,
    dynamic currentHustle,
    DateTime? levelEntryDate,
    int? hcEarnedInLevel,
    String? language,
    Map<String, DateTime>? taskCooldowns,
    int? dailyStreak,
    DateTime? createdAt,
    int? dailyTapEarnings,
    DateTime? lastTapResetDate,
    String? phoneNumber,
    String? fullName,
    String? nationalId,
    String? cryptoWalletAddress,
    String? cryptoNetwork,
    List<PendingReward>? pendingRewards,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      hcBalance: hcBalance ?? this.hcBalance,
      rankPoints: rankPoints ?? this.rankPoints,
      level: level ?? this.level,
      currentHustle: currentHustle ?? this.currentHustle,
      levelEntryDate: levelEntryDate ?? this.levelEntryDate,
      hcEarnedInLevel: hcEarnedInLevel ?? this.hcEarnedInLevel,
      language: language ?? this.language,
      taskCooldowns: taskCooldowns ?? this.taskCooldowns,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      createdAt: createdAt ?? this.createdAt,
      dailyTapEarnings: dailyTapEarnings ?? this.dailyTapEarnings,
      lastTapResetDate: lastTapResetDate ?? this.lastTapResetDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      cryptoWalletAddress: cryptoWalletAddress ?? this.cryptoWalletAddress,
      cryptoNetwork: cryptoNetwork ?? this.cryptoNetwork,
      pendingRewards: pendingRewards ?? this.pendingRewards,
    );
  }

  // Visual-only Kwanza balance - DEPRECATED/REMOVED to use RemoteConfig rate
  // int get kzBalance => (hcBalance / 8).floor();
}
