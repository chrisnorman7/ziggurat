/// Test walls.
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('Walls tests', () {
    test('Initialisation', () {
      final w = Box<Wall>('Wall', Point(0, 0), Point(5, 0), Wall());
      expect(w.start, equals(Point<int>(0, 0)));
      expect(w.end, equals(Point<int>(5, 0)));
      expect(w.type is Wall, isTrue);
    });
  });
}