import 'package:flutter/foundation.dart';

enum PayoutStatus { pending, processing, completed, rejected }

enum PayoutMethodType { multicaixaExpress, cryptoTransfer }

@immutable
class Payout {
  final String id;
  final String userId;
  final int amountHc;
  final double amountKwanza;
  final double conversionRate;
  final PayoutMethodType payoutMethod;
  final PayoutStatus status;
  final String? phoneNumber;
  final String? fullName;
  final String? nationalId;
  final String? cryptoWalletAddress;
  final String? cryptoNetwork;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? processedAt;
  final DateTime? completedAt;

  const Payout({
    required this.id,
    required this.userId,
    required this.amountHc,
    required this.amountKwanza,
    required this.conversionRate,
    required this.payoutMethod,
    required this.status,
    this.phoneNumber,
    this.fullName,
    this.nationalId,
    this.cryptoWalletAddress,
    this.cryptoNetwork,
    this.rejectionReason,
    required this.createdAt,
    this.processedAt,
    this.completedAt,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['id'].toString(), // Handle PydanticObjectId as string
      userId: json['user_id']?.toString() ?? '', // Backend may not include this
      amountHc: json['amount_hc'] ?? 0,
      amountKwanza: (json['amount_kwanza'] as num?)?.toDouble() ?? 0.0,
      conversionRate:
          (json['conversion_rate'] as num?)?.toDouble() ??
          10.0, // Default fallback
      payoutMethod: PayoutMethodType.values.firstWhere(
        (e) => e.name == json['payout_method']?.replaceAll('_', ''),
        orElse: () => json['payout_method'] == 'multicaixa_express'
            ? PayoutMethodType.multicaixaExpress
            : PayoutMethodType.cryptoTransfer,
      ),
      status: PayoutStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PayoutStatus.pending, // Default fallback
      ),
      phoneNumber: json['phone_number'],
      fullName: json['full_name'],
      nationalId: json['national_id'],
      cryptoWalletAddress: json['crypto_wallet_address'],
      cryptoNetwork: json['crypto_network'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount_hc': amountHc,
      'amount_kwanza': amountKwanza,
      'conversion_rate': conversionRate,
      'payout_method': payoutMethod == PayoutMethodType.multicaixaExpress
          ? 'multicaixa_express'
          : 'crypto_transfer',
      'status': status.name,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'national_id': nationalId,
      'crypto_wallet_address': cryptoWalletAddress,
      'crypto_network': cryptoNetwork,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  String get statusDisplayText {
    switch (status) {
      case PayoutStatus.pending:
        return 'Pending Review';
      case PayoutStatus.processing:
        return 'Processing';
      case PayoutStatus.completed:
        return 'Completed';
      case PayoutStatus.rejected:
        return 'Rejected';
    }
  }

  String get methodDisplayText {
    switch (payoutMethod) {
      case PayoutMethodType.multicaixaExpress:
        return 'Multicaixa Express';
      case PayoutMethodType.cryptoTransfer:
        return 'Crypto Transfer';
    }
  }
}
