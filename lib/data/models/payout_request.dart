import 'package:flutter/foundation.dart';

@immutable
class PayoutRequest {
  final int amountHc;
  final String payoutMethod;
  final String? phoneNumber;
  final String? fullName;
  final String? nationalId;
  final String? cryptoWalletAddress;
  final String? cryptoNetwork;

  const PayoutRequest({
    required this.amountHc,
    required this.payoutMethod,
    this.phoneNumber,
    this.fullName,
    this.nationalId,
    this.cryptoWalletAddress,
    this.cryptoNetwork,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'amount_hc': amountHc,
      'payout_method': payoutMethod,
    };

    if (phoneNumber != null) json['phone_number'] = phoneNumber;
    if (fullName != null) json['full_name'] = fullName;
    if (nationalId != null) json['national_id'] = nationalId;
    if (cryptoWalletAddress != null)
      json['crypto_wallet_address'] = cryptoWalletAddress;
    if (cryptoNetwork != null) json['crypto_network'] = cryptoNetwork;

    return json;
  }
}
