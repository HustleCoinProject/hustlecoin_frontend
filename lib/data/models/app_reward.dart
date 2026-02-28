import 'package:flutter/foundation.dart';

@immutable
class AppReward {
  final String rewardType; // "HP" or "ITEM"
  final int? hpAmount;
  final String? itemId;
  final String? itemName;
  final String? itemDescription;
  final int quantity;

  const AppReward({
    required this.rewardType,
    this.hpAmount,
    this.itemId,
    this.itemName,
    this.itemDescription,
    required this.quantity,
  });

  factory AppReward.fromJson(Map<String, dynamic> json) {
    return AppReward(
      rewardType: json['reward_type'] ?? 'HP',
      hpAmount: json['hp_amount'],
      itemId: json['item_id'],
      itemName: json['item_name'],
      itemDescription: json['item_description'],
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reward_type': rewardType,
      'hp_amount': hpAmount,
      'item_id': itemId,
      'item_name': itemName,
      'item_description': itemDescription,
      'quantity': quantity,
    };
  }

  bool get isHcReward => rewardType == 'HP';
  bool get isItemReward => rewardType == 'ITEM';
}
