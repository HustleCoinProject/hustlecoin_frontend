class Mission {
  final String id;
  final String title;
  final String description;
  final int rewardAmount;
  final int durationSeconds; // Duration of the mission in seconds
  final String difficulty;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardAmount,
    required this.durationSeconds,
    required this.difficulty,
  });
}
