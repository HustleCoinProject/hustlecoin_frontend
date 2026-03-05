import 'package:flutter/foundation.dart';

@immutable
class TaskCompletionResponse {
  final String message;
  final int newBalance;
  final int newRankPoints;
  final int rankPointsEarned;
  final DateTime? cooldownExpiresAt;
  final int? newEnergy;
  final int? newActivity;

  const TaskCompletionResponse({
    required this.message,
    required this.newBalance,
    required this.newRankPoints,
    required this.rankPointsEarned,
    this.cooldownExpiresAt,
    this.newEnergy,
    this.newActivity,
  });

  factory TaskCompletionResponse.fromJson(Map<String, dynamic> json) {
    return TaskCompletionResponse(
      message: json['message'] ?? '',
      newBalance: json['new_balance'] ?? 0,
      newRankPoints: json['new_rank_points'] ?? 0,
      rankPointsEarned: json['rank_points_earned'] ?? 0,
      cooldownExpiresAt: json['cooldown_expires_at'] != null
          ? DateTime.parse(json['cooldown_expires_at']).toLocal()
          : null,
      newEnergy: json['new_energy'],
      newActivity: json['new_activity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'new_balance': newBalance,
      'new_rank_points': newRankPoints,
      'rank_points_earned': rankPointsEarned,
      'cooldown_expires_at': cooldownExpiresAt?.toIso8601String(),
      'new_energy': newEnergy,
      'new_activity': newActivity,
    };
  }
}
