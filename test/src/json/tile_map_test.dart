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
        '.setTileFlags',
        () {
          // ignore: prefer_const_constructors
          final tileMap = TileMap(width: 10, height: 10, tiles: {})
            ..setTileFlags(point: const Point(0, 0), flags: 14);
          expect(tileMap.getTileFlags(const Point(0, 0)), 14);
          tileMap.setTileFlags(point: const Point(3, 3), flags: 15);
          expect(tileMap.getTileFlags(const Point(0, 0)), 14);
          expect(tileMap.getTileFlags(const Point(3, 3)), 15);
        },
      );
      test(
        '.setTileFlag',
        () {
          // ignore: prefer_const_constructors
          final tileMap = TileMap(width: 10, height: 10, tiles: {})
            ..setTileFlag(point: const Point(0, 0), flag: 1);
          expect(tileMap.getTileFlags(const Point(0, 0)), 1);
          tileMap.setTileFlag(point: const Point(0, 0), flag: 2);
          expect(tileMap.getTileFlags(const Point(0, 0)), 3);
          tileMap.setTileFlag(point: const Point(5, 5), flag: 1);
          expect(tileMap.getTileFlags(const Point(5, 5)), 1);
        },
      );
      test(
        '.clearTileFlag',
        () {
          // ignore: prefer_const_constructors
          final tileMap = TileMap(width: 10, height: 10, tiles: {})
            ..setTileFlag(point: const Point(0, 0), flag: 5)
            ..clearTileFlag(point: const Point(0, 0), flag: 2);
          expect(tileMap.getTileFlags(const Point(0, 0)), 5);
          tileMap.clearTileFlag(point: const Point(0, 0), flag: 1);
          expect(tileMap.getTileFlags(const Point(0, 0)), 4);
          tileMap
            ..setTileFlags(point: const Point(5, 5), flags: 7)
            ..clearTileFlag(point: const Point(5, 5), flag: 2);
          expect(tileMap.getTileFlags(const Point(5, 5)), 5);
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
