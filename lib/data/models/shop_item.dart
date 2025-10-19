import 'package:flutter/foundation.dart';

@immutable
class ShopItem {
  final String itemId;
  final String name;
  final String description;
  final int price;
  final String itemType;
  final Map<String, dynamic> metadata;

  const ShopItem({
    required this.itemId,
    required this.name,
    required this.description,
    required this.price,
    required this.itemType,
    required this.metadata,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      itemId: json['item_id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      itemType: json['item_type'],
      metadata: json['metadata'],
    );
  }
}
