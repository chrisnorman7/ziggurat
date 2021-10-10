/// Test the [BoxMap] class.
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('GameMap tests', () {
    test('Initialise', () {
      final map = BoxMap(
          name: 'Test Map',
          boxes: [Box('Only box', Point(0, 0), Point(9, 9), Surface())]);
      expect(map.boxes.length, equals(1));
      expect(map.initialCoordinates, equals(Point(0.0, 0.0)));
      expect(map.initialHeading, isZero);
    });
  });
}
