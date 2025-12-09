import 'package:flutter/foundation.dart';

@immutable
class SafeLockReward {
  final String rewardType; // "HC" or "ITEM"
  final int? hcAmount;
  final String? itemId;
  final String? itemName;
  final String? itemDescription;
  final int quantity;

  const SafeLockReward({
    required this.rewardType,
    this.hcAmount,
    this.itemId,
    this.itemName,
    this.itemDescription,
    required this.quantity,
  });

  factory SafeLockReward.fromJson(Map<String, dynamic> json) {
    return SafeLockReward(
      rewardType: json['reward_type'] ?? 'HC',
      hcAmount: json['hc_amount'],
      itemId: json['item_id'],
      itemName: json['item_name'],
      itemDescription: json['item_description'],
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reward_type': rewardType,
      'hc_amount': hcAmount,
      'item_id': itemId,
      'item_name': itemName,
      'item_description': itemDescription,
      'quantity': quantity,
    };
  }

  bool get isHcReward => rewardType == 'HC';
  bool get isItemReward => rewardType == 'ITEM';
}
