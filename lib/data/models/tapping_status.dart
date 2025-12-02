import 'package:flutter/foundation.dart';

@immutable
class TappingStatus {
  final int dailyEarnings;
  final int dailyLimit;
  final int remainingTaps;
  final bool canTap;
  final DateTime? nextResetAt;

  const TappingStatus({
    required this.dailyEarnings,
    required this.dailyLimit,
    required this.remainingTaps,
    required this.canTap,
    this.nextResetAt,
  });

  factory TappingStatus.fromJson(Map<String, dynamic> json) {
    return TappingStatus(
      dailyEarnings: json['daily_earnings'] ?? 0,
      dailyLimit: json['daily_limit'] ?? 200,
      remainingTaps: json['remaining_taps'] ?? 0,
      canTap: json['can_tap'] ?? false,
      nextResetAt: json['next_reset_at'] != null
          ? DateTime.parse(json['next_reset_at'])
          : null,
    );
  }

  bool get hasReachedDailyLimit => remainingTaps <= 0 || !canTap;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TappingStatus &&
        other.dailyEarnings == dailyEarnings &&
        other.dailyLimit == dailyLimit &&
        other.remainingTaps == remainingTaps &&
        other.canTap == canTap &&
        other.nextResetAt == nextResetAt;
  }

  @override
  int get hashCode {
    return dailyEarnings.hashCode ^
        dailyLimit.hashCode ^
        remainingTaps.hashCode ^
        canTap.hashCode ^
        nextResetAt.hashCode;
  }

  @override
  String toString() {
    return 'TappingStatus(dailyEarnings: $dailyEarnings, dailyLimit: $dailyLimit, remainingTaps: $remainingTaps, canTap: $canTap, nextResetAt: $nextResetAt)';
  }
}
