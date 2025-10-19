import 'package:flutter/foundation.dart';

@immutable
class MyLandTile {
  final String h3Index;
  final DateTime purchasedAt;
  final int purchasePrice;

  const MyLandTile({
    required this.h3Index,
    required this.purchasedAt,
    required this.purchasePrice,
  });

  factory MyLandTile.fromJson(Map<String, dynamic> json) {
    return MyLandTile(
      h3Index: json['h3_index'],
      purchasedAt: DateTime.parse(json['purchased_at']),
      purchasePrice: json['purchase_price'],
    );
  }
}
