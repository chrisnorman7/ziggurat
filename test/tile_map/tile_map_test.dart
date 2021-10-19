import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/mapping.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('TileMap', () {
    test('Initialise', () {
      final map = TileMap(
          tiles: [Tile(coordinates: Point(0, 0))], width: 10, height: 20);
      expect(map.start, equals(Point(0, 0)));
      expect(map.width, equals(10));
      expect(map.height, equals(20));
      expect(map.end, equals(Point(map.width, map.height)));
      expect(map.tiles.length, equals(1));
      expect(map.footstepSound, isNull);
      expect(map.turnSound, isNull);
      expect(
          map.wallMessage,
          predicate((value) =>
              value is Message && value.sound == null && value.text == null));
    });
    test('.containsPoint', () {
      final tileMap = TileMap(tiles: [], width: 10, height: 11);
      expect(tileMap.containsPoint(tileMap.start.toDouble()), isTrue);
      expect(tileMap.containsPoint(tileMap.end.toDouble()), isTrue);
      expect(tileMap.containsPoint(tileMap.cornerNw.toDouble()), isTrue);
      expect(tileMap.containsPoint(tileMap.cornerSe.toDouble()), isTrue);
      expect(tileMap.containsPoint(Point(-1.0, 0.0)), isFalse);
      expect(tileMap.containsPoint(Point(0.0, -1.0)), isFalse);
      expect(
          tileMap.containsPoint(Point(-1, tileMap.height.toDouble())), isFalse);
      expect(tileMap.containsPoint(Point(tileMap.width.toDouble(), -1.0)),
          isFalse);
      expect(
          tileMap
              .containsPoint(Point(tileMap.width + 1.0, tileMap.height + 1.0)),
          isFalse);
    });
  });
}
