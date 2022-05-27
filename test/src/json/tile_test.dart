import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group(
    'Tile class',
    () {
      test(
        'Initialise',
        () {
          const tile = Tile(x: 0, y: 1, value: 2);
          expect(tile.x, isZero);
          expect(tile.y, 1);
          expect(tile.value, 2);
        },
      );
      test(
        '.coordinates',
        () {
          const tile = Tile(x: 8, y: 10, value: 0);
          expect(tile.coordinates, const Point(8, 10));
        },
      );
      test(
        '.hasFlag',
        () {
          const mine = 1;
          const hole = mine * 2;
          const wall = hole * 2;
          const death = wall * 2;
          const tile = Tile(x: 3, y: 3, value: hole | death);
          expect(tile.hasFlag(death), true);
          expect(tile.hasFlag(hole), true);
          expect(tile.hasFlag(mine), false);
        },
      );
    },
  );
}
