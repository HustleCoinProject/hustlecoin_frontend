import 'package:flutter/foundation.dart';

@immutable
class PayoutInfo {
  final int availableHc;
  final double conversionRate;
  final int minimumPayoutHc;
  final bool hasPendingPayout;
  final String? phoneNumber;
  final String? fullName;
  final String? nationalId;
  final String? bankIban;
  final String? bankName;

  const PayoutInfo({
    required this.availableHc,
    required this.conversionRate,
    required this.minimumPayoutHc,
    required this.hasPendingPayout,
    this.phoneNumber,
    this.fullName,
    this.nationalId,
    this.bankIban,
    this.bankName,
  });

  factory PayoutInfo.fromJson(Map<String, dynamic> json) {
    return PayoutInfo(
      availableHc: json['available_balance_hc'] ?? 0,
      conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 10.0,
      minimumPayoutHc: json['min_payout_hc'] ?? 0,
      hasPendingPayout: json['has_pending_payout'] ?? false,
      phoneNumber: json['phone_number'],
      fullName: json['full_name'],
      nationalId: json['national_id'],
      bankIban: json['bank_iban'],
      bankName: json['bank_name'],
    );
  }

  double get availableKwanza => availableHc / conversionRate;
  double get minimumPayoutKwanza => minimumPayoutHc / conversionRate;
  
  bool get canPayout => availableHc >= minimumPayoutHc && !hasPendingPayout;
}

@immutable
class PayoutMethods {
  final List<String> availableMethods;
  final Map<String, dynamic> requirements;

  const PayoutMethods({
    required this.availableMethods,
    required this.requirements,
  });

  factory PayoutMethods.fromJson(Map<String, dynamic> json) {
    return PayoutMethods(
      availableMethods: List<String>.from(json['available_methods']),
      requirements: Map<String, dynamic>.from(json['requirements']),
    );
  }

  bool get supportsMulticaixaExpress => availableMethods.contains('multicaixa_express');
  bool get supportsBankTransfer => availableMethods.contains('bank_transfer');
}