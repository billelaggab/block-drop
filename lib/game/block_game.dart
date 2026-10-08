import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../services/game_settings.dart';
import '../services/haptic_service.dart';
import '../services/sound_service.dart';
import 'game_board.dart';
import 'game_piece.dart';

class BlockGame extends FlameGame {
  final GameBoard board = GameBoard();

  final SoundService sound;
  final HapticService haptics;

  GameSettings settings;

  VoidCallback? onHudChanged;
  VoidCallback? onGameOver;

  double _fallTimer = 0;
  double _lockTimer = 0;
  double _clearTimer = 0;
  double _dropFlashTimer = 0;

  static const double _lockDelay = 0.50;
  static const double _clearDuration = 0.28;
  static const double _dropFlashDuration = 0.10;

  static const int _maxLockResets = 15;

  int _lockResetCount = 0;

  bool _gameOverEventSent = false;

  BlockGame({
    required this.sound,
    required this.haptics,
    required this.settings,
  }) {
    _applySettings();
  }

  void _applySettings() {
    sound.soundEnabled = settings.soundEnabled;
    sound.musicEnabled = settings.musicEnabled;
    haptics.enabled = settings.hapticsEnabled;
  }

  void updateSettings(GameSettings value) {
    settings = value;
    _applySettings();
  }

  @override
  Color backgroundColor() {
    return const Color(0xFF090D18);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (dt > 0.1) {
      dt = 0.1;
    }

    if (_dropFlashTimer > 0) {
      _dropFlashTimer -= dt;
      if (_dropFlashTimer < 0) _dropFlashTimer = 0;
    }

    if (board.isGameOver) {
      _notifyGameOverOnce();
      return;
    }

    if (board.isPaused) {
      return;
    }

    // ==========================================================
    // Line-clear animation logic
    // ==========================================================

    if (board.isClearing) {
      _clearTimer += dt;

      if (_clearTimer >= _clearDuration) {
        final count = board.pendingClearRows.length;

        // هنا يتم فعليًا حذف الأسطر من البيانات وتحديث الشبكة
        board.finishLineClear();

        _clearTimer = 0;
        _fallTimer = 0;
        _lockTimer = 0;
        _lockResetCount = 0;

        if (count >= 4) {
          sound.play(Sfx.tetris);
          haptics.heavy();
        } else {
          sound.play(Sfx.clear);
          haptics.strong();
        }

        onHudChanged?.call();

        if (board.isGameOver) {
          _notifyGameOverOnce();
        }
      }

      // مهم جداً: أثناء المسح، لا نقوم بأي حركة جاذبية أو قفل
      return;
    }

    // ==========================================================
    // Lock delay
    // ==========================================================

    if (board.isGrounded) {
      _lockTimer += dt;

      if (_lockTimer >= _lockDelay) {
        _lockCurrentPiece();
      }

      return;
    }

    _lockTimer = 0;

    // ==========================================================
    // Gravity
    // ==========================================================

    _fallTimer += dt;

    final interval = board.fallIntervalSeconds;

    while (_fallTimer >= interval && !board.isGrounded && !board.isGameOver) {
      _fallTimer -= interval;

      if (!board.stepDown()) {
        break;
      }
    }
  }

  void _notifyGameOverOnce() {
    if (_gameOverEventSent) return;

    _gameOverEventSent = true;

    sound.play(Sfx.gameOver);
    haptics.heavy();

    onHudChanged?.call();
    onGameOver?.call();
  }

  // ============================================================
  // Rendering
  // ============================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (size.x <= 0 || size.y <= 0) {
      return;
    }

    final cellSize = _cellSize;

    final boardWidth = GameBoard.width * cellSize;
    final boardHeight = GameBoard.height * cellSize;

    final originX = (size.x - boardWidth) / 2;
    final originY = (size.y - boardHeight) / 2;

    final boardRect = Rect.fromLTWH(originX, originY, boardWidth, boardHeight);

    // Board shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        boardRect.shift(const Offset(0, 5)),
        const Radius.circular(12),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.30),
    );

    // Board background
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(12)),
      Paint()..color = const Color(0xFF111827),
    );

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(12)),
    );

    _drawGrid(canvas, originX, originY, cellSize);

    _drawLockedBlocks(canvas, originX, originY, cellSize);

    // ==========================================
    // FIX: لا ترسم القطعة النشطة أو الظل أثناء مسح الأسطر
    // هذا يمنع التداخل البصري ويظهر السطر المختفي بوضوح
    // ==========================================
    if (!board.isGameOver && !board.isClearing) {
      if (settings.ghostEnabled) {
        _drawGhost(canvas, originX, originY, cellSize);
      }

      _drawActivePiece(canvas, originX, originY, cellSize);
    }

    _drawLineClearEffect(canvas, originX, originY, cellSize, boardWidth);

    _drawDropFlash(canvas, boardRect);

    canvas.restore();

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(12)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawGrid(
    Canvas canvas,
    double originX,
    double originY,
    double cellSize,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF243047).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int y = 0; y < GameBoard.height; y++) {
      for (int x = 0; x < GameBoard.width; x++) {
        canvas.drawRect(
          Rect.fromLTWH(
            originX + x * cellSize,
            originY + y * cellSize,
            cellSize,
            cellSize,
          ),
          paint,
        );
      }
    }
  }

  void _drawLockedBlocks(
    Canvas canvas,
    double originX,
    double originY,
    double cellSize,
  ) {
    for (int y = 0; y < GameBoard.height; y++) {
      for (int x = 0; x < GameBoard.width; x++) {
        final type = board.grid[y][x];

        if (type == null) continue;

        _drawBlock(
          canvas,
          Rect.fromLTWH(
            originX + x * cellSize,
            originY + y * cellSize,
            cellSize,
            cellSize,
          ),
          pieceColor(type),
        );
      }
    }
  }

  void _drawGhost(
    Canvas canvas,
    double originX,
    double originY,
    double cellSize,
  ) {
    final ghost = board.ghostPiece;

    if (ghost.y == board.activePiece.y && ghost.x == board.activePiece.x) {
      return;
    }

    for (final cell in ghost.cells) {
      final x = ghost.x + cell.x;
      final y = ghost.y + cell.y;

      if (y < 0) continue;

      final rect = Rect.fromLTWH(
        originX + x * cellSize,
        originY + y * cellSize,
        cellSize,
        cellSize,
      );

      final inner = rect.deflate(3);

      canvas.drawRRect(
        RRect.fromRectAndRadius(inner, const Radius.circular(4)),
        Paint()..color = pieceColor(ghost.type).withValues(alpha: 0.09),
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(inner, const Radius.circular(4)),
        Paint()
          ..color = pieceColor(ghost.type).withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  void _drawActivePiece(
    Canvas canvas,
    double originX,
    double originY,
    double cellSize,
  ) {
    final piece = board.activePiece;

    for (final cell in piece.cells) {
      final x = piece.x + cell.x;
      final y = piece.y + cell.y;

      if (y < 0) continue;

      _drawBlock(
        canvas,
        Rect.fromLTWH(
          originX + x * cellSize,
          originY + y * cellSize,
          cellSize,
          cellSize,
        ),
        piece.color,
      );
    }
  }

  void _drawBlock(Canvas canvas, Rect rect, Color color) {
    final block = rect.deflate(1.4);

    canvas.drawRRect(
      RRect.fromRectAndRadius(block, const Radius.circular(4)),
      Paint()..color = color,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          block.left + 3,
          block.top + 3,
          block.width - 6,
          block.height * 0.16,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.24),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(block, const Radius.circular(4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawLineClearEffect(
    Canvas canvas,
    double originX,
    double originY,
    double cellSize,
    double boardWidth,
  ) {
    if (!board.isClearing) return;

    final progress = (_clearTimer / _clearDuration).clamp(0.0, 1.0);

    for (final row in board.pendingClearRows) {
      final opacity = progress < 0.5 ? progress * 2 : (1 - progress) * 2;

      canvas.drawRect(
        Rect.fromLTWH(originX, originY + row * cellSize, boardWidth, cellSize),
        Paint()..color = Colors.white.withValues(alpha: 0.85 * opacity),
      );
    }
  }

  void _drawDropFlash(Canvas canvas, Rect boardRect) {
    if (_dropFlashTimer <= 0) return;

    final progress = (_dropFlashTimer / _dropFlashDuration).clamp(0.0, 1.0);

    canvas.drawRect(
      boardRect,
      Paint()..color = Colors.white.withValues(alpha: 0.06 * progress),
    );
  }

  double get _cellSize {
    final availableWidth = size.x * 0.92;
    final availableHeight = size.y * 0.98;

    final widthCell = availableWidth / GameBoard.width;
    final heightCell = availableHeight / GameBoard.height;

    return widthCell < heightCell ? widthCell : heightCell;
  }

  // ============================================================
  // Locking
  // ============================================================

  void _lockCurrentPiece() {
    if (board.isGameOver || board.isPaused || board.isClearing) {
      return;
    }

    final result = board.lockActivePiece();

    _fallTimer = 0;
    _lockTimer = 0;
    _lockResetCount = 0;

    sound.play(Sfx.lock);
    haptics.light();

    onHudChanged?.call();

    if (result.gameOver) {
      _notifyGameOverOnce();
    }
  }

  void _afterGroundAction() {
    if (!board.isGrounded) {
      _lockTimer = 0;
      return;
    }

    if (_lockResetCount < _maxLockResets) {
      _lockTimer = 0;
      _lockResetCount++;
    }
  }

  // ============================================================
  // Controls
  // ============================================================

  void moveLeft() {
    if (!board.canPlay) return;

    if (board.moveLeft()) {
      sound.play(Sfx.move);
      haptics.light();
      _afterGroundAction();
    }
  }

  void moveRight() {
    if (!board.canPlay) return;

    if (board.moveRight()) {
      sound.play(Sfx.move);
      haptics.light();
      _afterGroundAction();
    }
  }

  void moveDown() {
    if (!board.canPlay) return;

    if (board.stepDown(softDrop: true)) {
      _fallTimer = 0;
      _lockTimer = 0;
      onHudChanged?.call();
    }
  }

  void rotatePiece() {
    if (!board.canPlay) return;

    if (board.rotate()) {
      sound.play(Sfx.rotate);
      haptics.light();
      _afterGroundAction();
    }
  }

  void hardDrop() {
    if (!board.canPlay) return;

    board.hardDropDistance();

    sound.play(Sfx.drop);
    haptics.medium();

    _dropFlashTimer = _dropFlashDuration;

    _lockCurrentPiece();
  }

  void holdPiece() {
    if (!board.canPlay || !board.canHold) {
      return;
    }

    if (board.hold()) {
      sound.play(Sfx.hold);
      haptics.medium();

      _fallTimer = 0;
      _lockTimer = 0;
      _lockResetCount = 0;

      onHudChanged?.call();

      if (board.isGameOver) {
        _notifyGameOverOnce();
      }
    }
  }

  void pauseGame() {
    if (board.isGameOver || board.isPaused) {
      return;
    }

    board.setPaused(true);
    _lockTimer = 0;

    sound.pauseMusic();
    onHudChanged?.call();
  }

  void resumeGame() {
    if (board.isGameOver || !board.isPaused) {
      return;
    }

    board.setPaused(false);

    _fallTimer = 0;
    _lockTimer = 0;

    sound.resumeMusic();
    onHudChanged?.call();
  }

  void togglePause() {
    if (board.isPaused) {
      resumeGame();
    } else {
      pauseGame();
    }
  }

  void restart() {
    board.reset();

    _fallTimer = 0;
    _lockTimer = 0;
    _clearTimer = 0;
    _dropFlashTimer = 0;
    _lockResetCount = 0;
    _gameOverEventSent = false;

    onHudChanged?.call();
  }
}
