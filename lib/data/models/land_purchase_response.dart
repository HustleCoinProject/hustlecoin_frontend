import 'package:flutter/foundation.dart';

@immutable
class LandPurchaseResponse {
  final String message;
  final String h3Index;
  final int newBalance;
  final int rankPointsEarned;
  final int newRankPoints;

  const LandPurchaseResponse({
    required this.message,
    required this.h3Index,
    required this.newBalance,
    required this.rankPointsEarned,
    required this.newRankPoints,
  });

  factory LandPurchaseResponse.fromJson(Map<String, dynamic> json) {
    return LandPurchaseResponse(
      message: json['message'] ?? '',
      h3Index: json['h3_index'] ?? '',
      newBalance: json['new_balance'] ?? 0,
      rankPointsEarned: json['rank_points_earned'] ?? 0,
      newRankPoints: json['new_rank_points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'h3_index': h3Index,
      'new_balance': newBalance,
      'rank_points_earned': rankPointsEarned,
      'new_rank_points': newRankPoints,
    };
  }
}