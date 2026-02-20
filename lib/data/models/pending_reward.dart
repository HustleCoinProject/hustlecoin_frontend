import 'package:flutter/foundation.dart';
import 'app_reward.dart';

@immutable
class PendingReward {
  final String id;
  final String source;
  final AppReward reward;
  final DateTime createdAt;

  const PendingReward({
    required this.id,
    required this.source,
    required this.reward,
    required this.createdAt,
  });

  factory PendingReward.fromJson(Map<String, dynamic> json) {
    return PendingReward(
      id: json['id'],
      source: json['source'],
      reward: AppReward.fromJson(json['reward']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'reward': reward.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
