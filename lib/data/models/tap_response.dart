import 'package:flutter/foundation.dart';

@immutable
class TapResponse {
  final bool success;
  final String message;
  final int hcEarned;
  final int rankPointsEarned;
  final int newBalance;
  final int newRankPoints;
  final int dailyEarnings;
  final int dailyLimit;
  final int remainingTaps;
  final DateTime? nextResetAt;

  const TapResponse({
    required this.success,
    required this.message,
    required this.hcEarned,
    required this.rankPointsEarned,
    required this.newBalance,
    required this.newRankPoints,
    required this.dailyEarnings,
    required this.dailyLimit,
    required this.remainingTaps,
    this.nextResetAt,
  });

  factory TapResponse.fromJson(Map<String, dynamic> json) {
    return TapResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      hcEarned: json['hc_earned'] ?? 0,
      rankPointsEarned: json['rank_points_earned'] ?? 0,
      newBalance: json['new_balance'] ?? 0,
      newRankPoints: json['new_rank_points'] ?? 0,
      dailyEarnings: json['daily_earnings'] ?? 0,
      dailyLimit: json['daily_limit'] ?? 200,
      remainingTaps: json['remaining_taps'] ?? 0,
      nextResetAt: json['next_reset_at'] != null
          ? DateTime.parse(json['next_reset_at'])
          : null,
    );
  }
}
