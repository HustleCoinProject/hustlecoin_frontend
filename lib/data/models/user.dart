import 'package:flutter/foundation.dart';
import 'pending_reward.dart';

@immutable
class User {
  final String id;
  final String username;
  final String email;
  final int hpScore;
  final int rankPoints;
  final int level;
  final dynamic
  currentHustle; // Can be String (old format) or Map<String, String> (new format)
  final DateTime levelEntryDate;
  final int hpEarnedInLevel;
  final String language;
  final Map<String, DateTime> taskCooldowns;
  final int dailyStreak;
  final DateTime createdAt;
  final int dailyTapEarnings;
  final DateTime? lastTapResetDate;

  // Energy and Activity Systems
  final int energy;
  final int maxEnergy;
  final DateTime energyUpdatedAt;
  final int activity;
  final int maxActivity;
  final DateTime activityUpdatedAt;

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
    required this.hpScore,
    required this.rankPoints,
    required this.level,
    required this.currentHustle,
    required this.levelEntryDate,
    required this.hpEarnedInLevel,
    required this.language,
    required this.taskCooldowns,
    required this.dailyStreak,
    required this.createdAt,
    required this.dailyTapEarnings,
    this.lastTapResetDate,
    required this.energy,
    required this.maxEnergy,
    required this.energyUpdatedAt,
    required this.activity,
    required this.maxActivity,
    required this.activityUpdatedAt,
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
      hpScore: json['hp_score'],
      rankPoints: json['rank_points'] ?? 0,
      level: json['level'],
      currentHustle: json['current_hustle'],
      levelEntryDate: DateTime.parse(json['level_entry_date']),
      hpEarnedInLevel: json['hp_earned_in_level'],
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
      energy: json['energy'] ?? 100,
      maxEnergy: json['max_energy'] ?? 100,
      energyUpdatedAt: json['energy_updated_at'] != null
          ? DateTime.parse(json['energy_updated_at'])
          : DateTime.now(),
      activity: json['activity'] ?? 0,
      maxActivity: json['max_activity'] ?? 100,
      activityUpdatedAt: json['activity_updated_at'] != null
          ? DateTime.parse(json['activity_updated_at'])
          : DateTime.now(),
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
    int? hpScore,
    int? rankPoints,
    int? level,
    dynamic currentHustle,
    DateTime? levelEntryDate,
    int? hpEarnedInLevel,
    String? language,
    Map<String, DateTime>? taskCooldowns,
    int? dailyStreak,
    DateTime? createdAt,
    int? dailyTapEarnings,
    DateTime? lastTapResetDate,
    int? energy,
    int? maxEnergy,
    DateTime? energyUpdatedAt,
    int? activity,
    int? maxActivity,
    DateTime? activityUpdatedAt,
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
      hpScore: hpScore ?? this.hpScore,
      rankPoints: rankPoints ?? this.rankPoints,
      level: level ?? this.level,
      currentHustle: currentHustle ?? this.currentHustle,
      levelEntryDate: levelEntryDate ?? this.levelEntryDate,
      hpEarnedInLevel: hpEarnedInLevel ?? this.hpEarnedInLevel,
      language: language ?? this.language,
      taskCooldowns: taskCooldowns ?? this.taskCooldowns,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      createdAt: createdAt ?? this.createdAt,
      dailyTapEarnings: dailyTapEarnings ?? this.dailyTapEarnings,
      lastTapResetDate: lastTapResetDate ?? this.lastTapResetDate,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      energyUpdatedAt: energyUpdatedAt ?? this.energyUpdatedAt,
      activity: activity ?? this.activity,
      maxActivity: maxActivity ?? this.maxActivity,
      activityUpdatedAt: activityUpdatedAt ?? this.activityUpdatedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      cryptoWalletAddress: cryptoWalletAddress ?? this.cryptoWalletAddress,
      cryptoNetwork: cryptoNetwork ?? this.cryptoNetwork,
      pendingRewards: pendingRewards ?? this.pendingRewards,
    );
  }

  // Visual-only Kwanza balance - DEPRECATED/REMOVED to use RemoteConfig rate
  // int get kzBalance => (hpScore / 8).floor();
}
