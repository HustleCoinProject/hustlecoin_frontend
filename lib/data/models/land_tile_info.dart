import 'package:flutter/foundation.dart';

@immutable
class LandTileInfo {
  final String h3Index;
  final String ownerId;

  const LandTileInfo({required this.h3Index, required this.ownerId});

  factory LandTileInfo.fromJson(Map<String, dynamic> json) {
    return LandTileInfo(h3Index: json['h3_index'], ownerId: json['owner_id']);
  }
}
