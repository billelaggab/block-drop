import 'package:flutter/material.dart';

import '../game/game_piece.dart';

class PiecePreview extends StatelessWidget {
  final PieceType? type;
  final double width;
  final double height;

  const PiecePreview({
    super.key,
    required this.type,
    this.width = 72,
    this.height = 42,
  });

  @override
  Widget build(BuildContext context) {
    if (type == null) {
      return SizedBox(
        width: width,
        height: height,
        child: const Center(
          child: Text(
            '—',
            style: TextStyle(color: Colors.white30, fontSize: 20),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: PiecePreviewPainter(type!)),
    );
  }
}

class PiecePreviewPainter extends CustomPainter {
  final PieceType type;

  PiecePreviewPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final cells = pieceShapes[type]!.first;

    int minX = cells.first.x;
    int maxX = cells.first.x;
    int minY = cells.first.y;
    int maxY = cells.first.y;

    for (final cell in cells) {
      if (cell.x < minX) minX = cell.x;
      if (cell.x > maxX) maxX = cell.x;
      if (cell.y < minY) minY = cell.y;
      if (cell.y > maxY) maxY = cell.y;
    }

    final columns = maxX - minX + 1;
    final rows = maxY - minY + 1;

    final cellSize = [
      size.width / columns,
      size.height / rows,
      17.0,
    ].reduce((a, b) => a < b ? a : b);

    final drawWidth = columns * cellSize;
    final drawHeight = rows * cellSize;

    final startX = (size.width - drawWidth) / 2;
    final startY = (size.height - drawHeight) / 2;

    final color = pieceColor(type);

    for (final cell in cells) {
      final rect = Rect.fromLTWH(
        startX + (cell.x - minX) * cellSize + 1,
        startY + (cell.y - minY) * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()..color = color,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left + 2, rect.top + 2, rect.width - 4, 2),
          const Radius.circular(1),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.22),
      );
    }
  }

  @override
  bool shouldRepaint(covariant PiecePreviewPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}
