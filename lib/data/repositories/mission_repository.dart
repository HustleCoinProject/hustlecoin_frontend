import 'package:hustlecoin/data/models/mission.dart';

class MissionRepository {
  List<Mission> getMissions() {
    return [
      const Mission(
        id: 'mission_1',
        title: 'Warm Up Bundle',
        description: 'Complete these 3 games to warm up your skills!',
        rewardAmount: 200,
        games: ['balloon_pop', 'snake', 'runner'],
        difficulty: 'Easy',
      ),
      const Mission(
        id: 'mission_2',
        title: 'Agility Test',
        description: 'Test your reflexes with these fast-paced games.',
        rewardAmount: 500,
        games: ['pong', 'seagull', 'balloon_pop'],
        difficulty: 'Medium',
      ),
      const Mission(
        id: 'mission_3',
        title: 'Master Challenge',
        description: 'Only the best can complete this bundle.',
        rewardAmount: 1000,
        games: ['snake', 'runner', 'pong'],
        difficulty: 'Hard',
      ),
    ];
  }
}
