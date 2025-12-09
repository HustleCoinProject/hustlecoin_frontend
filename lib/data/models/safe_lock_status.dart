import 'package:flutter/foundation.dart';

@immutable
class SafeLockStatus {
  final int safeLockAmount;
  final DateTime? lockedUntil;
  final bool isLocked;
  final bool canClaim;
  final double timeRemainingSeconds;
  final int totalSafeLockGlobal;

  const SafeLockStatus({
    required this.safeLockAmount,
    this.lockedUntil,
    required this.isLocked,
    required this.canClaim,
    required this.timeRemainingSeconds,
    required this.totalSafeLockGlobal,
  });

  factory SafeLockStatus.fromJson(Map<String, dynamic> json) {
    return SafeLockStatus(
      safeLockAmount: json['safe_lock_amount'] ?? 0,
      lockedUntil: json['locked_until'] != null
          ? DateTime.parse(json['locked_until'])
          : null,
      isLocked: json['is_locked'] ?? false,
      canClaim: json['can_claim'] ?? false,
      timeRemainingSeconds: (json['time_remaining_seconds'] ?? 0.0).toDouble(),
      totalSafeLockGlobal: json['total_safe_lock_global'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'safe_lock_amount': safeLockAmount,
      'locked_until': lockedUntil?.toIso8601String(),
      'is_locked': isLocked,
      'can_claim': canClaim,
      'time_remaining_seconds': timeRemainingSeconds,
      'total_safe_lock_global': totalSafeLockGlobal,
    };
  }
}
