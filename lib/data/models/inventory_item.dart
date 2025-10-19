import 'package:flutter/foundation.dart';

@immutable
class InventoryItem {
  final String itemId;
  final int quantity;
  final DateTime purchasedAt;
  final DateTime? expiresAt;

  const InventoryItem({
    required this.itemId,
    required this.quantity,
    required this.purchasedAt,
    this.expiresAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      itemId: json['item_id'],
      quantity: json['quantity'],
      purchasedAt: DateTime.parse(json['purchased_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
    );
  }
}
