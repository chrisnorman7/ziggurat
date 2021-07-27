/// Test walls.
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('Walls tests', () {
    test('Initialisation', () {
      var w = Box<Wall>('Wall', Point(0, 0), Point(5, 0), Wall());
      expect(w.start, equals(Point<int>(0, 0)));
      expect(w.end, equals(Point<int>(5, 0)));
      expect(w.type is Wall, isTrue);
      expect(w.type.surmountable, isFalse);
      w = Box<Wall>('Wall 2', w.start, w.end, Wall(surmountable: true));
      expect(w.type.surmountable, isTrue);
    });
  });
}
