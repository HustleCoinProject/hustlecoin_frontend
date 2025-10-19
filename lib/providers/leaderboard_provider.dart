import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/leaderboard_entry.dart';
import 'foundational_providers.dart';

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((
  ref,
) async {
  return ref.read(apiRepositoryProvider).getLeaderboard();
});
