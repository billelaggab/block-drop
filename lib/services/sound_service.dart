import 'package:audioplayers/audioplayers.dart';

enum Sfx {
  move,
  rotate,
  drop,
  lock,
  clear,
  tetris,
  hold,
  gameOver,
}

class SoundService {
  final List<AudioPlayer> _sfxPlayers = [];
  final AudioPlayer _musicPlayer = AudioPlayer();

  int _index = 0;

  bool _initialized = false;
  bool _assetsAvailable = false;

  bool soundEnabled = true;
  bool musicEnabled = true;

  static const Map<Sfx, String> _sfxAssets = {
    Sfx.move: 'audio/move.wav',
    Sfx.rotate: 'audio/rotate.wav',
    Sfx.drop: 'audio/drop.wav',
    Sfx.lock: 'audio/lock.wav',
    Sfx.clear: 'audio/clear.wav',
    Sfx.tetris: 'audio/tetris.wav',
    Sfx.hold: 'audio/hold.wav',
    Sfx.gameOver: 'audio/game_over.wav',
  };

  static const String _music =
      'audio/music.mp3';

  Future<void> init({
    bool assetsAvailable = false,
  }) async {
    if (_initialized) return;

    _initialized = true;
    _assetsAvailable = assetsAvailable;

    for (int i = 0; i < 4; i++) {
      final player = AudioPlayer();

      try {
        await player.setReleaseMode(
          ReleaseMode.stop,
        );

        await player.setPlayerMode(
          PlayerMode.lowLatency,
        );
      } catch (_) {}

      _sfxPlayers.add(player);
    }

    try {
      await _musicPlayer.setReleaseMode(
        ReleaseMode.loop,
      );

      await _musicPlayer.setVolume(
        0.30,
      );
    } catch (_) {}
  }

  void play(Sfx effect) {
    if (!soundEnabled ||
        !_assetsAvailable ||
        _sfxPlayers.isEmpty) {
      return;
    }

    final path = _sfxAssets[effect];

    if (path == null) return;

    final player =
        _sfxPlayers[_index];

    _index =
        (_index + 1) %
            _sfxPlayers.length;

    player
        .play(
          AssetSource(path),
          volume: 0.70,
        )
        .catchError((_) {});
  }

  Future<void> startMusic() async {
    if (!musicEnabled ||
        !_assetsAvailable) {
      return;
    }

    try {
      await _musicPlayer.play(
        AssetSource(_music),
      );
    } catch (_) {}
  }

  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (!musicEnabled ||
        !_assetsAvailable) {
      return;
    }

    try {
      await _musicPlayer.resume();
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    for (final player
        in _sfxPlayers) {
      await player.dispose();
    }

    _sfxPlayers.clear();

    await _musicPlayer.dispose();
  }
}