import 'dart:ui' show Color;

enum PieceType { i, o, t, l, j, s, z }

class CellPosition {
  final int x;
  final int y;

  const CellPosition(this.x, this.y);
}

/// قطعة غير قابلة للتغيير.
/// أي حركة تنتج نسخة جديدة عبر copyWith.
class GamePiece {
  final PieceType type;
  final int x;
  final int y;
  final int rotation;

  const GamePiece({
    required this.type,
    required this.x,
    required this.y,
    this.rotation = 0,
  });

  factory GamePiece.spawn(PieceType type, {int boardWidth = 10}) {
    return GamePiece(type: type, x: (boardWidth ~/ 2) - 2, y: -1);
  }

  List<CellPosition> get cells {
    final shapes = pieceShapes[type]!;
    return shapes[rotation % shapes.length];
  }

  int get rotationStates => pieceShapes[type]!.length;

  Color get color => pieceColor(type);

  GamePiece copyWith({int? x, int? y, int? rotation}) {
    return GamePiece(
      type: type,
      x: x ?? this.x,
      y: y ?? this.y,
      rotation: rotation ?? this.rotation,
    );
  }
}

Color pieceColor(PieceType type) {
  switch (type) {
    case PieceType.i:
      return const Color(0xFF22D3EE);
    case PieceType.o:
      return const Color(0xFFFACC15);
    case PieceType.t:
      return const Color(0xFFA855F7);
    case PieceType.l:
      return const Color(0xFFF97316);
    case PieceType.j:
      return const Color(0xFF3B82F6);
    case PieceType.s:
      return const Color(0xFF22C55E);
    case PieceType.z:
      return const Color(0xFFEF4444);
  }
}

const Map<PieceType, List<List<CellPosition>>> pieceShapes = {
  PieceType.i: [
    [
      CellPosition(0, 1),
      CellPosition(1, 1),
      CellPosition(2, 1),
      CellPosition(3, 1),
    ],
    [
      CellPosition(2, 0),
      CellPosition(2, 1),
      CellPosition(2, 2),
      CellPosition(2, 3),
    ],
  ],
  PieceType.o: [
    [
      CellPosition(1, 0),
      CellPosition(2, 0),
      CellPosition(1, 1),
      CellPosition(2, 1),
    ],
  ],
  PieceType.t: [
    [
      CellPosition(1, 0),
      CellPosition(0, 1),
      CellPosition(1, 1),
      CellPosition(2, 1),
    ],
    [
      CellPosition(1, 0),
      CellPosition(1, 1),
      CellPosition(2, 1),
      CellPosition(1, 2),
    ],
    [
      CellPosition(0, 1),
      CellPosition(1, 1),
      CellPosition(2, 1),
      CellPosition(1, 2),
    ],
    [
      CellPosition(1, 0),
      CellPosition(0, 1),
      CellPosition(1, 1),
      CellPosition(1, 2),
    ],
  ],
  PieceType.l: [
    [
      CellPosition(2, 0),
      CellPosition(0, 1),
      CellPosition(1, 1),
      CellPosition(2, 1),
    ],
    [
      CellPosition(1, 0),
      CellPosition(1, 1),
      CellPosition(1, 2),
      CellPosition(2, 2),
    ],
    [
      CellPosition(0, 1),
      CellPosition(1, 1),
      CellPosition(2, 1),
      CellPosition(0, 2),
    ],
    [
      CellPosition(0, 0),
      CellPosition(1, 0),
      CellPosition(1, 1),
      CellPosition(1, 2),
    ],
  ],
  PieceType.j: [
    [
      CellPosition(0, 0),
      CellPosition(0, 1),
      CellPosition(1, 1),
      CellPosition(2, 1),
    ],
    [
      CellPosition(1, 0),
      CellPosition(2, 0),
      CellPosition(1, 1),
      CellPosition(1, 2),
    ],
    [
      CellPosition(0, 1),
      CellPosition(1, 1),
      CellPosition(2, 1),
      CellPosition(2, 2),
    ],
    [
      CellPosition(1, 0),
      CellPosition(1, 1),
      CellPosition(0, 2),
      CellPosition(1, 2),
    ],
  ],
  PieceType.s: [
    [
      CellPosition(1, 0),
      CellPosition(2, 0),
      CellPosition(0, 1),
      CellPosition(1, 1),
    ],
    [
      CellPosition(1, 0),
      CellPosition(1, 1),
      CellPosition(2, 1),
      CellPosition(2, 2),
    ],
  ],
  PieceType.z: [
    [
      CellPosition(0, 0),
      CellPosition(1, 0),
      CellPosition(1, 1),
      CellPosition(2, 1),
    ],
    [
      CellPosition(2, 0),
      CellPosition(1, 1),
      CellPosition(2, 1),
      CellPosition(1, 2),
    ],
  ],
};
