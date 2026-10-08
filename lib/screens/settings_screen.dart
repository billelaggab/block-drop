import 'package:flutter/material.dart';

import '../services/game_settings.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final GameSettings settings;

  const SettingsScreen({super.key, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _service = SettingsService();

  late GameSettings settings;

  @override
  void initState() {
    super.initState();
    settings = widget.settings;
  }

  Future<void> _save(GameSettings value) async {
    setState(() {
      settings = value;
    });

    await _service.save(value);
  }

  Future<void> _close() async {
    await _service.save(settings);

    if (!mounted) return;
    Navigator.pop(context, settings);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _close();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF090D18),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('SETTINGS'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _close,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _SettingSwitch(
              title: 'Sound Effects',
              subtitle: 'Movement and gameplay sounds',
              icon: Icons.volume_up_outlined,
              value: settings.soundEnabled,
              onChanged: (value) {
                _save(settings.copyWith(soundEnabled: value));
              },
            ),
            _SettingSwitch(
              title: 'Music',
              subtitle: 'Background music',
              icon: Icons.music_note_outlined,
              value: settings.musicEnabled,
              onChanged: (value) {
                _save(settings.copyWith(musicEnabled: value));
              },
            ),
            _SettingSwitch(
              title: 'Haptic Feedback',
              subtitle: 'Vibration during gameplay',
              icon: Icons.vibration_outlined,
              value: settings.hapticsEnabled,
              onChanged: (value) {
                _save(settings.copyWith(hapticsEnabled: value));
              },
            ),
            _SettingSwitch(
              title: 'Ghost Piece',
              subtitle: 'Show the landing position',
              icon: Icons.grid_view_outlined,
              value: settings.ghostEnabled,
              onChanged: (value) {
                _save(settings.copyWith(ghostEnabled: value));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111827),
      margin: const EdgeInsets.only(bottom: 10),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: const Color(0xFF8B5CF6)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      ),
    );
  }
}
