import 'package:flutter/foundation.dart';

@immutable
class TaskStatus {
  final String taskId;
  final String description;
  final int reward;
  final int rankPoints;
  final String type;
  final int cooldownSeconds;
  final bool isAvailable;
  final DateTime? cooldownExpiresAt;
  final int? secondsUntilAvailable;

  const TaskStatus({
    required this.taskId,
    required this.description,
    required this.reward,
    required this.rankPoints,
    required this.type,
    required this.cooldownSeconds,
    required this.isAvailable,
    this.cooldownExpiresAt,
    this.secondsUntilAvailable,
  });

  factory TaskStatus.fromJson(Map<String, dynamic> json) {
    return TaskStatus(
      taskId: json['task_id'],
      description: json['description'],
      reward: json['reward'],
      rankPoints: json['rank_points'] ?? 0,
      type: json['type'],
      cooldownSeconds: json['cooldown_seconds'],
      isAvailable: json['is_available'],
      cooldownExpiresAt: json['cooldown_expires_at'] != null
          ? DateTime.parse(json['cooldown_expires_at'])
          : null,
      secondsUntilAvailable: json['seconds_until_available'],
    );
  }
}
