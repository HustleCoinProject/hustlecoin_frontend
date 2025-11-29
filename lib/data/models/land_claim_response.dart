class LandClaimResponse {
  final String message;
  final int totalIncome;
  final int tilesProcessed;
  final int newBalance;
  final int rankPointsEarned;
  final int newRankPoints;
  final DateTime nextClaimAvailableAt;

  LandClaimResponse({
    required this.message,
    required this.totalIncome,
    required this.tilesProcessed,
    required this.newBalance,
    required this.rankPointsEarned,
    required this.newRankPoints,
    required this.nextClaimAvailableAt,
  });

  factory LandClaimResponse.fromJson(Map<String, dynamic> json) {
    return LandClaimResponse(
      message: json['message'] ?? '',
      totalIncome: json['total_income'] ?? 0,
      tilesProcessed: json['tiles_processed'] ?? 0,
      newBalance: json['new_balance'] ?? 0,
      rankPointsEarned: json['rank_points_earned'] ?? 0,
      newRankPoints: json['new_rank_points'] ?? 0,
      nextClaimAvailableAt: DateTime.parse(
        json['next_claim_available_at'],
      ).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'total_income': totalIncome,
      'tiles_processed': tilesProcessed,
      'new_balance': newBalance,
      'rank_points_earned': rankPointsEarned,
      'new_rank_points': newRankPoints,
      'next_claim_available_at': nextClaimAvailableAt.toIso8601String(),
    };
  }
}
