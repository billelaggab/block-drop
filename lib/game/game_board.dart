import 'dart:math';

import 'game_piece.dart';
import 'piece_bag.dart';

class LockResult {
  final bool gameOver;
  final List<int> clearedRows;

  const LockResult({required this.gameOver, required this.clearedRows});

  int get clearedCount => clearedRows.length;

  bool get hasClears => clearedRows.isNotEmpty;
}

class GameBoard {
  static const int width = 10;
  static const int height = 20;
  static const int nextQueueSize = 3;

  final PieceBag _bag = PieceBag();

  late List<List<PieceType?>> grid;
  late GamePiece activePiece;

  final List<PieceType> nextQueue = [];

  PieceType? heldPiece;

  bool canHold = true;
  bool isGameOver = false;
  bool isPaused = false;

  final List<int> pendingClearRows = [];

  int score = 0;
  int lines = 0;
  int level = 1;
  int combo = 0;
  int piecesPlaced = 0;

  GameBoard() {
    reset();
  }

  // ============================================================
  // Reset
  // ============================================================

  void reset() {
    grid = List.generate(height, (_) => List<PieceType?>.filled(width, null));

    _bag.reset();

    nextQueue.clear();
    pendingClearRows.clear();

    for (int i = 0; i < nextQueueSize; i++) {
      nextQueue.add(_bag.next());
    }

    heldPiece = null;

    canHold = true;
    isGameOver = false;
    isPaused = false;

    score = 0;
    lines = 0;
    level = 1;
    combo = 0;
    piecesPlaced = 0;

    _spawnFromQueue();
  }

  // ============================================================
  // State
  // ============================================================

  bool get isClearing => pendingClearRows.isNotEmpty;

  bool get canPlay => !isGameOver && !isPaused && !isClearing;

  PieceType get nextPiece => nextQueue.first;

  // ============================================================
  // Spawn
  // ============================================================

  void _spawnFromQueue() {
    if (nextQueue.isEmpty) {
      for (int i = 0; i < nextQueueSize; i++) {
        nextQueue.add(_bag.next());
      }
    }

    final type = nextQueue.removeAt(0);

    nextQueue.add(_bag.next());

    activePiece = GamePiece.spawn(type, boardWidth: width);

    if (!_isValid(activePiece)) {
      isGameOver = true;
    }
  }

  // ============================================================
  // Collision
  // ============================================================

  bool _isValid(GamePiece piece) {
    for (final cell in piece.cells) {
      final x = piece.x + cell.x;

      final y = piece.y + cell.y;

      if (x < 0 || x >= width) {
        return false;
      }

      if (y >= height) {
        return false;
      }

      if (y >= 0 && grid[y][x] != null) {
        return false;
      }
    }

    return true;
  }

  bool get isGrounded {
    if (!canPlay) {
      return false;
    }

    final candidate = activePiece.copyWith(y: activePiece.y + 1);

    return !_isValid(candidate);
  }

  // ============================================================
  // Movement
  // ============================================================

  bool moveLeft() {
    if (!canPlay) {
      return false;
    }

    final candidate = activePiece.copyWith(x: activePiece.x - 1);

    if (!_isValid(candidate)) {
      return false;
    }

    activePiece = candidate;

    return true;
  }

  bool moveRight() {
    if (!canPlay) {
      return false;
    }

    final candidate = activePiece.copyWith(x: activePiece.x + 1);

    if (!_isValid(candidate)) {
      return false;
    }

    activePiece = candidate;

    return true;
  }

  bool stepDown({bool softDrop = false}) {
    if (!canPlay) {
      return false;
    }

    final candidate = activePiece.copyWith(y: activePiece.y + 1);

    if (!_isValid(candidate)) {
      return false;
    }

    activePiece = candidate;

    if (softDrop) {
      score += 1;
    }

    return true;
  }

  // ============================================================
  // Rotation
  // ============================================================

  bool rotate() {
    if (!canPlay) {
      return false;
    }

    final nextRotation =
        (activePiece.rotation + 1) % activePiece.rotationStates;

    final rotated = activePiece.copyWith(rotation: nextRotation);

    if (_isValid(rotated)) {
      activePiece = rotated;
      return true;
    }

    const kicks = [
      CellPosition(-1, 0),
      CellPosition(1, 0),
      CellPosition(-2, 0),
      CellPosition(2, 0),
      CellPosition(0, -1),
      CellPosition(-1, -1),
      CellPosition(1, -1),
    ];

    for (final kick in kicks) {
      final candidate = rotated.copyWith(
        x: rotated.x + kick.x,
        y: rotated.y + kick.y,
      );

      if (_isValid(candidate)) {
        activePiece = candidate;
        return true;
      }
    }

    return false;
  }

  // ============================================================
  // Hard Drop
  // ============================================================

  int hardDropDistance() {
    if (!canPlay) {
      return 0;
    }

    int distance = 0;

    var piece = activePiece;

    while (true) {
      final candidate = piece.copyWith(y: piece.y + 1);

      if (!_isValid(candidate)) {
        break;
      }

      piece = candidate;
      distance++;
    }

    activePiece = piece;

    score += distance * 2;

    return distance;
  }

  // ============================================================
  // Hold
  // ============================================================

  bool hold() {
    if (!canPlay || !canHold) {
      return false;
    }

    final currentType = activePiece.type;

    if (heldPiece == null) {
      heldPiece = currentType;

      _spawnFromQueue();
    } else {
      final swap = heldPiece!;

      heldPiece = currentType;

      activePiece = GamePiece.spawn(swap, boardWidth: width);

      if (!_isValid(activePiece)) {
        isGameOver = true;
      }
    }

    canHold = false;

    return true;
  }

  // ============================================================
  // Ghost
  // ============================================================

  GamePiece get ghostPiece {
    var ghost = activePiece;

    while (true) {
      final candidate = ghost.copyWith(y: ghost.y + 1);

      if (!_isValid(candidate)) {
        break;
      }

      ghost = candidate;
    }

    return ghost;
  }

  // ============================================================
  // Pause
  // ============================================================

  void togglePause() {
    if (isGameOver) {
      return;
    }

    isPaused = !isPaused;
  }

  void setPaused(bool value) {
    if (isGameOver) {
      return;
    }

    isPaused = value;
  }

  // ============================================================
  // Lock
  // ============================================================

  LockResult lockActivePiece() {
    if (isGameOver || isClearing) {
      return LockResult(gameOver: isGameOver, clearedRows: const []);
    }

    bool aboveTop = false;

    for (final cell in activePiece.cells) {
      final x = activePiece.x + cell.x;

      final y = activePiece.y + cell.y;

      if (y < 0) {
        aboveTop = true;
        continue;
      }

      if (x < 0 || x >= width || y >= height) {
        continue;
      }

      grid[y][x] = activePiece.type;
    }

    piecesPlaced++;

    if (aboveTop) {
      isGameOver = true;

      return const LockResult(gameOver: true, clearedRows: []);
    }

    final fullRows = <int>[];

    for (int y = 0; y < height; y++) {
      if (_isRowFull(y)) {
        fullRows.add(y);
      }
    }

    if (fullRows.isNotEmpty) {
      pendingClearRows
        ..clear()
        ..addAll(fullRows);

      return LockResult(
        gameOver: false,
        clearedRows: List<int>.unmodifiable(fullRows),
      );
    }

    combo = 0;
    canHold = true;

    _spawnFromQueue();

    return LockResult(gameOver: isGameOver, clearedRows: const []);
  }

  bool _isRowFull(int row) {
    if (row < 0 || row >= height) {
      return false;
    }

    for (int x = 0; x < width; x++) {
      if (grid[row][x] == null) {
        return false;
      }
    }

    return true;
  }

  // ============================================================
  // Line Clear
  // ============================================================

  void finishLineClear() {
    if (pendingClearRows.isEmpty) {
      return;
    }

    // نحفظ عدد الأسطر قبل تنظيف الحالة.
    final cleared = pendingClearRows.length;

    final rowsToRemove = pendingClearRows.toSet();

    // نبني شبكة جديدة بدل حذف عناصر من List
    // أثناء تغير الفهارس.
    final remainingRows = <List<PieceType?>>[];

    for (int y = 0; y < height; y++) {
      if (!rowsToRemove.contains(y)) {
        remainingRows.add(List<PieceType?>.from(grid[y]));
      }
    }

    final emptyRowCount = height - remainingRows.length;

    final newGrid = <List<PieceType?>>[];

    for (int i = 0; i < emptyRowCount; i++) {
      newGrid.add(List<PieceType?>.filled(width, null));
    }

    newGrid.addAll(remainingRows);

    // حماية invariant اللوحة.
    if (newGrid.length != height) {
      throw StateError(
        'Invalid board height after line clear: '
        '${newGrid.length}',
      );
    }

    grid = newGrid;

    pendingClearRows.clear();

    lines += cleared;

    level = 1 + (lines ~/ 10);

    combo++;

    _applyScore(cleared);

    canHold = true;

    _spawnFromQueue();
  }

  // ============================================================
  // Score
  // ============================================================

  void _applyScore(int cleared) {
    const baseScores = <int, int>{1: 100, 2: 300, 3: 500, 4: 800};

    score += (baseScores[cleared] ?? 0) * level;

    if (combo > 1) {
      score += 50 * (combo - 1) * level;
    }
  }

  // ============================================================
  // Speed
  // ============================================================

  double get fallIntervalSeconds {
    final milliseconds = max(80, 800 - ((level - 1) * 65));

    return milliseconds / 1000.0;
  }
  // ============================================================
  // Testing / diagnostics
  // ============================================================

  void debugSetCell({
    required int x,
    required int y,
    required PieceType? value,
  }) {
    assert(x >= 0 && x < width, 'x outside board');

    assert(y >= 0 && y < height, 'y outside board');

    grid[y][x] = value;
  }

  void debugFindCompletedRows() {
    pendingClearRows.clear();

    for (int y = 0; y < height; y++) {
      if (_isRowFull(y)) {
        pendingClearRows.add(y);
      }
    }
  }
}
