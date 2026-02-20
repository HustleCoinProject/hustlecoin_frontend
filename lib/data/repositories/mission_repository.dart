import 'package:hustlecoin/data/models/mission.dart';

class MissionRepository {
  List<Mission> getMissions() {
    return [
      const Mission(
        id: 'mission_1',
        title: 'Warm Up Task',
        description: 'Start your hustle with a quick 5-minute task!',
        rewardAmount: 200,
        durationSeconds: 300, // 5 minutes
        difficulty: 'Easy',
      ),
      const Mission(
        id: 'mission_2',
        title: 'Agility Task',
        description: 'Complete a 15-minute task for a solid reward.',
        rewardAmount: 250,
        durationSeconds: 900, // 15 minutes
        difficulty: 'Medium',
      ),
      const Mission(
        id: 'mission_3',
        title: 'Master Challenge',
        description: 'A 30-minute task for dedicated hustlers.',
        rewardAmount: 300,
        durationSeconds: 1800, // 30 minutes
        difficulty: 'Hard',
      ),
      const Mission(
        id: 'mission_4',
        title: 'Hustle God',
        description: 'The ultimate 1-hour task.',
        rewardAmount: 350,
        durationSeconds: 3600, // 60 minutes
        difficulty: 'Expert',
      ),
    ];
  }
}
