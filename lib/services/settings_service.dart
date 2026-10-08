import 'package:shared_preferences/shared_preferences.dart';

import 'game_settings.dart';

class SettingsService {
  static const _sound = 'settings_sound';
  static const _music = 'settings_music';
  static const _haptics = 'settings_haptics';
  static const _ghost = 'settings_ghost';

  Future<GameSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    return GameSettings(
      soundEnabled: prefs.getBool(_sound) ?? true,
      musicEnabled: prefs.getBool(_music) ?? true,
      hapticsEnabled: prefs.getBool(_haptics) ?? true,
      ghostEnabled: prefs.getBool(_ghost) ?? true,
    );
  }

  Future<void> save(GameSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_sound, settings.soundEnabled);
    await prefs.setBool(_music, settings.musicEnabled);
    await prefs.setBool(_haptics, settings.hapticsEnabled);
    await prefs.setBool(_ghost, settings.ghostEnabled);
  }
}
