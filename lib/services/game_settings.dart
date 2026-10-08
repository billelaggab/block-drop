class GameSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final bool ghostEnabled;

  const GameSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.ghostEnabled = true,
  });

  GameSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    bool? ghostEnabled,
  }) {
    return GameSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      ghostEnabled: ghostEnabled ?? this.ghostEnabled,
    );
  }
}
