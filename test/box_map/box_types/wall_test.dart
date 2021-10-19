/// Test walls.
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/mapping.dart';

void main() {
  group('Walls tests', () {
    test('Initialisation', () {
      final w = Box<Wall>(
          name: 'Wall', start: Point(0, 0), end: Point(5, 0), type: Wall());
      expect(w.start, equals(Point<int>(0, 0)));
      expect(w.end, equals(Point<int>(5, 0)));
      expect(w.type is Wall, isTrue);
    });
  });
}
