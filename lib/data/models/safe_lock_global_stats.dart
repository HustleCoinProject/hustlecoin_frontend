import 'package:flutter/foundation.dart';

@immutable
class SafeLockGlobalStats {
  final int totalSafeLockGlobal;
  final int totalUsersWithSafeLock;
  final double averageSafeLockAmount;

  const SafeLockGlobalStats({
    required this.totalSafeLockGlobal,
    required this.totalUsersWithSafeLock,
    required this.averageSafeLockAmount,
  });

  factory SafeLockGlobalStats.fromJson(Map<String, dynamic> json) {
    return SafeLockGlobalStats(
      totalSafeLockGlobal: json['total_safe_lock_global'] ?? 0,
      totalUsersWithSafeLock: json['total_users_with_safe_lock'] ?? 0,
      averageSafeLockAmount: (json['average_safe_lock_amount'] ?? 0.0)
          .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_safe_lock_global': totalSafeLockGlobal,
      'total_users_with_safe_lock': totalUsersWithSafeLock,
      'average_safe_lock_amount': averageSafeLockAmount,
    };
  }
}
