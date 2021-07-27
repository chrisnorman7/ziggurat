/// Ziggurat tests.
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

/// Imaginary game state.
class GameState {}

void main() {
  group('Ziggurat tests', () {
    test('Initialisation', () {
      final z = Ziggurat('Test');
      expect(z.name, equals('Test'));
      expect(z.ambiances, isEmpty);
      expect(z.initialCoordinates, equals(Point<int>(0, 0)));
      expect(z.randomSounds, isEmpty);
      expect(z.boxes, isEmpty);
    });
  });
}
