import 'dart:math';

import 'package:block_drop/game/game_piece.dart';
import 'package:block_drop/game/piece_bag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'every bag contains all seven piece types',
    () {
      final bag = PieceBag(
        random: Random(12345),
      );

      for (int bagIndex = 0;
          bagIndex < 20;
          bagIndex++) {
        final values = <PieceType>{};

        for (int i = 0; i < 7; i++) {
          values.add(
            bag.next(),
          );
        }

        expect(
          values.length,
          PieceType.values.length,
        );

        expect(
          values,
          containsAll(PieceType.values),
        );
      }
    },
  );
}