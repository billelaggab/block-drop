import 'package:block_drop/game/game_board.dart';
import 'package:block_drop/game/game_piece.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameBoard', () {
    test('new board has correct dimensions', () {
      final board = GameBoard();

      expect(board.grid.length, GameBoard.height);

      for (final row in board.grid) {
        expect(row.length, GameBoard.width);
      }
    });

    test('active piece can move down', () {
      final board = GameBoard();

      final oldY = board.activePiece.y;

      final moved = board.stepDown();

      expect(moved, isTrue);
      expect(board.activePiece.y, oldY + 1);
    });

    test('hard drop moves piece to ground', () {
      final board = GameBoard();

      final distance = board.hardDropDistance();

      expect(distance, greaterThan(0));
      expect(board.isGrounded, isTrue);
    });

    test('hold can only be used once before lock', () {
      final board = GameBoard();

      final firstType = board.activePiece.type;

      expect(board.hold(), isTrue);
      expect(board.heldPiece, firstType);
      expect(board.canHold, isFalse);

      final current = board.activePiece.type;

      expect(board.hold(), isFalse);
      expect(board.activePiece.type, current);
    });

    test('reset restores initial state', () {
      final board = GameBoard();

      board.stepDown(softDrop: true);
      board.hold();

      board.reset();

      expect(board.score, 0);
      expect(board.lines, 0);
      expect(board.level, 1);
      expect(board.combo, 0);
      expect(board.heldPiece, isNull);
      expect(board.isGameOver, isFalse);
      expect(board.isPaused, isFalse);
      expect(board.nextQueue.length, GameBoard.nextQueueSize);
    });

    test('single completed line is removed correctly', () {
      final board = GameBoard();

      _fillBottomRows(board, 1);

      final before = board.lines;

      board.debugFindCompletedRows();

      expect(board.pendingClearRows, [19]);

      board.finishLineClear();

      expect(board.lines, before + 1);
      expect(board.pendingClearRows, isEmpty);
      expect(_rowIsEmpty(board.grid[0]), isTrue);
      expect(board.grid.length, GameBoard.height);
    });

    test('two completed lines are removed correctly', () {
      final board = GameBoard();

      _fillBottomRows(board, 2);

      board.debugFindCompletedRows();

      expect(board.pendingClearRows, [18, 19]);

      board.finishLineClear();

      expect(board.lines, 2);
      expect(_rowIsEmpty(board.grid[0]), isTrue);
      expect(_rowIsEmpty(board.grid[1]), isTrue);
      expect(board.grid.length, GameBoard.height);
    });

    test('three completed lines are removed correctly', () {
      final board = GameBoard();

      _fillBottomRows(board, 3);

      board.debugFindCompletedRows();
      board.finishLineClear();

      expect(board.lines, 3);

      for (int y = 0; y < 3; y++) {
        expect(_rowIsEmpty(board.grid[y]), isTrue);
      }

      expect(board.grid.length, GameBoard.height);
    });

    test('four completed lines are removed correctly', () {
      final board = GameBoard();

      _fillBottomRows(board, 4);

      board.debugFindCompletedRows();
      board.finishLineClear();

      expect(board.lines, 4);
      expect(board.score, greaterThanOrEqualTo(800));

      for (int y = 0; y < 4; y++) {
        expect(_rowIsEmpty(board.grid[y]), isTrue);
      }

      expect(board.grid.length, GameBoard.height);
    });

    test('rows above cleared rows preserve their contents', () {
      final board = GameBoard();

      _fillBottomRows(board, 2);

      board.debugSetCell(x: 3, y: 17, value: PieceType.t);

      board.debugFindCompletedRows();
      board.finishLineClear();

      expect(board.grid[19][3], PieceType.t);
    });

    test('level increases every ten cleared lines', () {
      final board = GameBoard();

      for (int cycle = 0; cycle < 5; cycle++) {
        _fillBottomRows(board, 2);

        board.debugFindCompletedRows();
        board.finishLineClear();
      }

      expect(board.lines, 10);
      expect(board.level, 2);
    });
  });
}

void _fillBottomRows(GameBoard board, int count) {
  for (int y = GameBoard.height - count; y < GameBoard.height; y++) {
    for (int x = 0; x < GameBoard.width; x++) {
      board.debugSetCell(x: x, y: y, value: PieceType.i);
    }
  }
}

bool _rowIsEmpty(List<PieceType?> row) {
  return row.every((cell) => cell == null);
}
