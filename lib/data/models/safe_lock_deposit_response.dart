import 'package:flutter/foundation.dart';

@immutable
class SafeLockDepositResponse {
  final bool success;
  final String message;
  final int newBalance;
  final int safeLockAmount;
  final DateTime lockedUntil;

  const SafeLockDepositResponse({
    required this.success,
    required this.message,
    required this.newBalance,
    required this.safeLockAmount,
    required this.lockedUntil,
  });

  factory SafeLockDepositResponse.fromJson(Map<String, dynamic> json) {
    return SafeLockDepositResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      newBalance: json['new_balance'] ?? 0,
      safeLockAmount: json['safe_lock_amount'] ?? 0,
      lockedUntil: DateTime.parse(json['locked_until']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'new_balance': newBalance,
      'safe_lock_amount': safeLockAmount,
      'locked_until': lockedUntil.toIso8601String(),
    };
  }
}
