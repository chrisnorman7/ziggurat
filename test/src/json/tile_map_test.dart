import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group(
    'TileMap class',
    () {
      test(
        'Initialise',
        () {
          const tileMap = TileMap(width: 10, height: 11);
          expect(tileMap.width, 10);
          expect(tileMap.height, 11);
          expect(tileMap.defaultFlags, 0);
          expect(tileMap.tiles, isEmpty);
        },
      );
      test(
        '.getTileFlags',
        () {
          const tileMap = TileMap(
            width: 10,
            height: 10,
            defaultFlags: 3,
            tiles: {
              0: {0: 8},
              3: {3: 7},
              8: {8: 14}
            },
          );
          expect(tileMap.getTileFlags(const Point(0, 0)), 8);
          expect(tileMap.getTileFlags(const Point(1, 1)), tileMap.defaultFlags);
          expect(tileMap.getTileFlags(const Point(8, 8)), 14);
        },
      );
      test(
        '.validCoordinates',
        () {
          const tileMap = TileMap(width: 10, height: 10);
          expect(tileMap.validCoordinates(const Point(0, 0)), true);
          expect(tileMap.validCoordinates(const Point(1, 1)), true);
          expect(
            tileMap
                .validCoordinates(Point(tileMap.width - 1, tileMap.height - 1)),
            true,
          );
          expect(
            tileMap.validCoordinates(Point(tileMap.width, tileMap.height)),
            false,
          );
        },
      );
    },
  );
}
