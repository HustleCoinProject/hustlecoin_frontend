import 'package:flutter/foundation.dart';

@immutable
class LevelStatus {
  final int currentLevel;
  final dynamic
  currentHustle; // Can be String (old format) or Map<String, String> (new format)
  final double daysInLevelProgress;
  final int daysInLevelRequired;
  final int hpEarnedInLevelProgress;
  final int hpEarnedInLevelRequired;
  final int upgradeFee;
  final bool isEligibleForUpgrade;

  const LevelStatus({
    required this.currentLevel,
    required this.currentHustle,
    required this.daysInLevelProgress,
    required this.daysInLevelRequired,
    required this.hpEarnedInLevelProgress,
    required this.hpEarnedInLevelRequired,
    required this.upgradeFee,
    required this.isEligibleForUpgrade,
  });

  factory LevelStatus.fromJson(Map<String, dynamic> json) {
    return LevelStatus(
      currentLevel: json['current_level'],
      currentHustle: json['current_hustle'],
      daysInLevelProgress: (json['days_in_level_progress'] as num).toDouble(),
      daysInLevelRequired: json['days_in_level_required'],
      hpEarnedInLevelProgress: json['hp_earned_in_level_progress'],
      hpEarnedInLevelRequired: json['hp_earned_in_level_required'],
      upgradeFee: json['upgrade_fee'],
      isEligibleForUpgrade: json['is_eligible_for_upgrade'],
    );
  }
}
