import 'package:flutter/foundation.dart';

@immutable
class Task {
  final String taskId;
  final String description;
  final int reward;
  final int rankPoints;
  final String type;
  final int cooldownSeconds;

  const Task({
    required this.taskId,
    required this.description,
    required this.reward,
    required this.rankPoints,
    required this.type,
    required this.cooldownSeconds,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['task_id'],
      description: json['description'],
      reward: json['reward'],
      rankPoints: json['rank_points'] ?? 0,
      type: json['type'],
      cooldownSeconds: json['cooldown_seconds'],
    );
  }
}
