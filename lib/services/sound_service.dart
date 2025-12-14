import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SoundType {
  click('assets/sounds/click.wav'),
  switchSound('assets/sounds/switch.wav'),
  earnCoins('assets/sounds/earn-coins.ogg');

  const SoundType(this.path);
  final String path;
}

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  static const String _soundEnabledKey = 'sound_enabled';

  // Initialize the sound service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    } catch (e) {
    }
  }

  // Get current sound enabled state
  bool get isSoundEnabled => _soundEnabled;

  // Toggle sound on/off
  Future<void> toggleSound() async {
    try {
      _soundEnabled = !_soundEnabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundEnabledKey, _soundEnabled);
    } catch (e) {
    }
  }

  // Play a sound by type
  Future<void> playSound(SoundType soundType) async {
    if (!_soundEnabled) {
      return;
    }

    try {
      await _audioPlayer.play(
        AssetSource(soundType.path.replaceFirst('assets/', '')),
      );
    } catch (e) {
    }
  }

  // Convenience methods for specific sounds
  Future<void> playClick() => playSound(SoundType.click);
  Future<void> playSwitch() => playSound(SoundType.switchSound);
  Future<void> playEarnCoins() => playSound(SoundType.earnCoins);

  // Dispose resources
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
    }
  }
}
