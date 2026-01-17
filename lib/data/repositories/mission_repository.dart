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
        rewardAmount: 250,
        games: ['pong', 'seagull', 'runner'],
        difficulty: 'Medium',
      ),
      const Mission(
        id: 'mission_3',
        title: 'Master Challenge',
        description: 'Only the best can complete this bundle.',
        rewardAmount: 300,
        games: ['snake', 'pong', 'seagull'],
        difficulty: 'Hard',
      ),
      const Mission(
        id: 'mission_4',
        title: 'Hustle God',
        description: 'The ultimate test of all your skills.',
        rewardAmount: 350,
        games: ['balloon_pop', 'runner', 'snake', 'seagull'],
        difficulty: 'Expert',
      ),
    ];
  }
}
