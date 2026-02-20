import 'package:flutter/foundation.dart';
import 'app_reward.dart';

@immutable
class SafeLockClaimResponse {
  final bool success;
  final String message;
  final int returnedAmount;
  final AppReward reward;
  final int newBalance;
  final int newSafeLockAmount;

  const SafeLockClaimResponse({
    required this.success,
    required this.message,
    required this.returnedAmount,
    required this.reward,
    required this.newBalance,
    required this.newSafeLockAmount,
  });

  factory SafeLockClaimResponse.fromJson(Map<String, dynamic> json) {
    return SafeLockClaimResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      returnedAmount: json['returned_amount'] ?? 0,
      reward: AppReward.fromJson(json['reward']),
      newBalance: json['new_balance'] ?? 0,
      newSafeLockAmount: json['new_safe_lock_amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'returned_amount': returnedAmount,
      'reward': reward.toJson(),
      'new_balance': newBalance,
      'new_safe_lock_amount': newSafeLockAmount,
    };
  }
}
