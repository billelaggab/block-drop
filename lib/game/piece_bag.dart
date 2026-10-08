import 'dart:math';

import 'game_piece.dart';

/// مولّد 7-bag: كل 7 قطع تحتوي على كل الأنواع مرة واحدة.
/// هذا يمنع التكرار الظالم أو الغياب الطويل لنوع معيّن.
class PieceBag {
  final Random _random;
  final List<PieceType> _pieces = [];

  PieceBag({Random? random}) : _random = random ?? Random();

  PieceType next() {
    if (_pieces.isEmpty) {
      _refill();
    }
    return _pieces.removeLast();
  }

  void reset() {
    _pieces.clear();
  }

  void _refill() {
    _pieces
      ..addAll(PieceType.values)
      ..shuffle(_random);
  }
}
