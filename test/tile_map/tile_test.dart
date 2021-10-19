import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/mapping.dart';

void main() {
  group('Tile', () {
    test('Initialisation', () {
      final tile = Tile(coordinates: Point(0, 0));
      expect(tile.coordinates, equals(Point(0, 0)));
      expect(tile.onEnter, isNull);
      expect(tile.onExit, isNull);
    });
  });
}
