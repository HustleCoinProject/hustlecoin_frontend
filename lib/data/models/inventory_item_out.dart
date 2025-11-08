import 'package:flutter/foundation.dart';

@immutable
class InventoryItemOut {
  final String itemId;
  final int quantity;
  final DateTime purchasedAt;
  final DateTime? expiresAt;
  final String name;
  final String description;
  final String itemType;
  final double? timeRemainingSeconds;

  const InventoryItemOut({
    required this.itemId,
    required this.quantity,
    required this.purchasedAt,
    this.expiresAt,
    required this.name,
    required this.description,
    required this.itemType,
    this.timeRemainingSeconds,
  });

  factory InventoryItemOut.fromJson(Map<String, dynamic> json) {
    return InventoryItemOut(
      itemId: json['item_id'],
      quantity: json['quantity'],
      purchasedAt: DateTime.parse(json['purchased_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      name: json['name'],
      description: json['description'],
      itemType: json['item_type'],
      timeRemainingSeconds: json['time_remaining_seconds'] != null
          ? (json['time_remaining_seconds'] as num).toDouble()
          : null,
    );
  }
}
