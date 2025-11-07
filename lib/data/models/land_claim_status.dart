class LandClaimStatus {
  final bool canClaim;
  final int availableIncome;
  final int tilesCount;
  final DateTime? lastClaimAt;
  final DateTime? nextClaimAvailableAt;
  final int? timeUntilNextClaimSeconds;

  LandClaimStatus({
    required this.canClaim,
    required this.availableIncome,
    required this.tilesCount,
    this.lastClaimAt,
    this.nextClaimAvailableAt,
    this.timeUntilNextClaimSeconds,
  });

  factory LandClaimStatus.fromJson(Map<String, dynamic> json) {
    return LandClaimStatus(
      canClaim: json['can_claim'] ?? false,
      availableIncome: json['available_income'] ?? 0,
      tilesCount: json['tiles_count'] ?? 0,
      lastClaimAt: json['last_claim_at'] != null
          ? DateTime.parse(json['last_claim_at']).toLocal()
          : null,
      nextClaimAvailableAt: json['next_claim_available_at'] != null
          ? DateTime.parse(json['next_claim_available_at']).toLocal()
          : null,
      timeUntilNextClaimSeconds: json['time_until_next_claim_seconds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'can_claim': canClaim,
      'available_income': availableIncome,
      'tiles_count': tilesCount,
      'last_claim_at': lastClaimAt?.toUtc().toIso8601String(),
      'next_claim_available_at': nextClaimAvailableAt
          ?.toUtc()
          .toIso8601String(),
      'time_until_next_claim_seconds': timeUntilNextClaimSeconds,
    };
  }
}
