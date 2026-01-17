class Mission {
  final String id;
  final String title;
  final String description;
  final int rewardAmount;
  final List<String> games; // List of game IDs (e.g., 'balloon_pop', 'snake')
  final String difficulty;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardAmount,
    required this.games,
    required this.difficulty,
  });
}
