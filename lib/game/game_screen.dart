import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/game_settings.dart';
import '../services/haptic_service.dart';
import '../services/score_service.dart';
import '../services/sound_service.dart';
import '../widgets/piece_preview.dart';
import 'block_game.dart';

class GameScreen extends StatefulWidget {
  final GameSettings settings;

  const GameScreen({super.key, required this.settings});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final ScoreService _scoreService = ScoreService();

  final SoundService _sound = SoundService();

  final HapticService _haptics = HapticService();

  late final BlockGame game;

  int highScore = 0;

  bool _resultSubmitted = false;

  double _horizontalAccumulator = 0;
  double _verticalAccumulator = 0;

  static const double _horizontalStep = 25;
  static const double _verticalStep = 28;

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    game = BlockGame(
      sound: _sound,
      haptics: _haptics,
      settings: widget.settings,
    );

    game.onHudChanged = _refreshHud;
    game.onGameOver = _handleGameOver;

    _initialize();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test Ad Unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  Future<void> _initialize() async {
    await _sound.init();

    final saved = await _scoreService.loadHighScore();

    if (!mounted) return;

    setState(() {
      highScore = saved;
    });

    await _sound.startMusic();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    game.onHudChanged = null;
    game.onGameOver = null;

    _bannerAd?.dispose();
    _interstitialAd?.dispose();

    _sound.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      game.pauseGame();
    }
  }

  void _refreshHud() {
    if (!mounted) return;

    if (game.board.score > highScore) {
      highScore = game.board.score;
    }

    setState(() {});
  }

  Future<void> _handleGameOver() async {
    if (_resultSubmitted) return;

    _resultSubmitted = true;

    _showInterstitialAd();

    final board = game.board;

    final isRecord = await _scoreService.submitGameResult(
      score: board.score,
      lines: board.lines,
    );

    if (!mounted) return;

    setState(() {
      if (isRecord || board.score > highScore) {
        highScore = board.score;
      }
    });
  }

  void _restart() {
    _resultSubmitted = false;
    game.restart();
  }

  Future<void> _exitGame() async {
    game.pauseGame();
    await _sound.stopMusic();

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // ============================================================
  // Gestures
  // ============================================================

  void _panStart(DragStartDetails details) {
    _horizontalAccumulator = 0;
    _verticalAccumulator = 0;
  }

  void _panUpdate(DragUpdateDetails details) {
    if (!game.board.canPlay) return;

    _horizontalAccumulator += details.delta.dx;

    _verticalAccumulator += details.delta.dy;

    while (_horizontalAccumulator >= _horizontalStep) {
      game.moveRight();
      _horizontalAccumulator -= _horizontalStep;
    }

    while (_horizontalAccumulator <= -_horizontalStep) {
      game.moveLeft();
      _horizontalAccumulator += _horizontalStep;
    }

    while (_verticalAccumulator >= _verticalStep) {
      game.moveDown();
      _verticalAccumulator -= _verticalStep;
    }

    if (_verticalAccumulator < 0) {
      _verticalAccumulator = 0;
    }
  }

  void _panEnd(DragEndDetails details) {
    if (!game.board.canPlay) return;

    final velocity = details.velocity.pixelsPerSecond;

    if (velocity.dy > 1200 && velocity.dy.abs() > velocity.dx.abs()) {
      game.hardDrop();
    }

    _horizontalAccumulator = 0;
    _verticalAccumulator = 0;
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final board = game.board;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _exitGame();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF080C17),
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                score: board.score,
                best: highScore,
                lines: board.lines,
                level: board.level,
                onPause: game.togglePause,
              ),

              _PreviewBar(game: game),

              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (board.canPlay) {
                            game.rotatePiece();
                          }
                        },
                        onPanStart: _panStart,
                        onPanUpdate: _panUpdate,
                        onPanEnd: _panEnd,
                        child: GameWidget(game: game),
                      ),
                    ),

                    if (board.isPaused && !board.isGameOver)
                      _PauseOverlay(
                        onResume: game.resumeGame,
                        onExit: _exitGame,
                      ),

                    if (board.isGameOver)
                      _GameOverOverlay(
                        score: board.score,
                        best: highScore,
                        lines: board.lines,
                        onRestart: _restart,
                        onExit: _exitGame,
                      ),
                  ],
                ),
              ),

              _GameControls(game: game),
              if (_isBannerLoaded && _bannerAd != null)
                Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int score;
  final int best;
  final int lines;
  final int level;
  final VoidCallback onPause;

  const _TopBar({
    required this.score,
    required this.best,
    required this.lines,
    required this.level,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(label: 'SCORE', value: '$score'),
                _Stat(
                  label: 'BEST',
                  value: '$best',
                  color: const Color(0xFFFACC15),
                ),
                _Stat(label: 'LINES', value: '$lines'),
                _Stat(label: 'LEVEL', value: '$level'),
              ],
            ),
          ),
          IconButton(onPressed: onPause, icon: const Icon(Icons.pause_rounded)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Stat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _PreviewBar extends StatelessWidget {
  final BlockGame game;

  const _PreviewBar({required this.game});

  @override
  Widget build(BuildContext context) {
    final board = game.board;

    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _PreviewCard(
              title: 'HOLD',
              enabled: board.canHold,
              child: PiecePreview(type: board.heldPiece),
            ),
            const Spacer(),
            _PreviewCard(
              title: 'NEXT',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < board.nextQueue.length && i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    PiecePreview(
                      type: board.nextQueue[i],
                      width: 49,
                      height: 38,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool enabled;

  const _PreviewCard({
    required this.title,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.4,
      duration: const Duration(milliseconds: 150),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _GameControls extends StatelessWidget {
  final BlockGame game;

  const _GameControls({required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RepeatButton(
                icon: Icons.arrow_left_rounded,
                action: game.moveLeft,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.rotate_right_rounded,
                action: game.rotatePiece,
              ),
              const SizedBox(width: 8),
              _RepeatButton(
                icon: Icons.arrow_downward_rounded,
                action: game.moveDown,
              ),
              const SizedBox(width: 8),
              _RepeatButton(
                icon: Icons.arrow_right_rounded,
                action: game.moveRight,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(
                icon: Icons.inventory_2_outlined,
                action: game.holdPiece,
                color: const Color(0xFF0F766E),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 126,
                height: 46,
                child: FilledButton.icon(
                  onPressed: game.hardDrop,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                  ),
                  icon: const Icon(Icons.vertical_align_bottom_rounded),
                  label: const Text(
                    'DROP',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback action;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.action,
    this.color = const Color(0xFF1F2937),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 46,
      child: FilledButton(
        onPressed: action,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _RepeatButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback action;

  const _RepeatButton({required this.icon, required this.action});

  @override
  State<_RepeatButton> createState() => _RepeatButtonState();
}

class _RepeatButtonState extends State<_RepeatButton> {
  Timer? _delay;
  Timer? _repeat;

  bool _pressed = false;

  void _start() {
    if (_pressed) return;

    _pressed = true;
    widget.action();

    _delay = Timer(const Duration(milliseconds: 180), () {
      if (!_pressed) return;

      _repeat = Timer.periodic(const Duration(milliseconds: 65), (_) {
        if (_pressed) {
          widget.action();
        }
      });
    });

    setState(() {});
  }

  void _stop() {
    _pressed = false;

    _delay?.cancel();
    _repeat?.cancel();

    _delay = null;
    _repeat = null;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _repeat?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _start(),
      onPointerUp: (_) => _stop(),
      onPointerCancel: (_) => _stop(),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 60),
        child: Container(
          width: 58,
          height: 46,
          decoration: BoxDecoration(
            color: _pressed ? const Color(0xFF334155) : const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(widget.icon),
        ),
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onExit;

  const _PauseOverlay({required this.onResume, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.76),
        alignment: Alignment.center,
        child: _DialogCard(
          children: [
            const Icon(
              Icons.pause_circle_outline,
              color: Color(0xFF8B5CF6),
              size: 62,
            ),
            const SizedBox(height: 12),
            const Text(
              'PAUSED',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 22),
            _DialogButton(
              label: 'RESUME',
              icon: Icons.play_arrow,
              action: onResume,
            ),
            const SizedBox(height: 8),
            _DialogButton(
              label: 'EXIT',
              icon: Icons.home_outlined,
              action: onExit,
              secondary: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final int score;
  final int best;
  final int lines;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const _GameOverOverlay({
    required this.score,
    required this.best,
    required this.lines,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.80),
        alignment: Alignment.center,
        child: _DialogCard(
          children: [
            const Icon(
              Icons.sports_esports_outlined,
              color: Color(0xFFEF4444),
              size: 58,
            ),
            const SizedBox(height: 10),
            const Text(
              'GAME OVER',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 15),
            Text(
              '$score',
              style: const TextStyle(
                color: Color(0xFFFACC15),
                fontSize: 36,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'BEST $best  •  LINES $lines',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 20),
            _DialogButton(
              label: 'PLAY AGAIN',
              icon: Icons.refresh,
              action: onRestart,
            ),
            const SizedBox(height: 8),
            _DialogButton(
              label: 'HOME',
              icon: Icons.home_outlined,
              action: onExit,
              secondary: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogCard extends StatelessWidget {
  final List<Widget> children;

  const _DialogCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback action;
  final bool secondary;

  const _DialogButton({
    required this.label,
    required this.icon,
    required this.action,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: secondary
          ? OutlinedButton.icon(
              onPressed: action,
              icon: Icon(icon),
              label: Text(label),
            )
          : FilledButton.icon(
              onPressed: action,
              icon: Icon(icon),
              label: Text(label),
            ),
    );
  }
}
