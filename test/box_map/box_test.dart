//// Test boxes.
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

/// The error which should be thrown when a [CustomTile] instance is activated.
class ActivateException implements Exception {
  /// Create an exception.
  ActivateException(this.message);

  /// The message.
  final String message;
}

/// A custom tile.
class CustomTile extends Box {
  /// Create an instance.
  CustomTile()
      : super(
            name: 'Custom Tile',
            start: Point(0, 0),
            end: Point(5, 5),
            type: Surface(),
            onActivate: () => throw ActivateException('Activate'));
}

void main() {
  group('boxes tests', () {
    test('Initialisation', () {
      final t = Box(
          name: 'Test tile',
          start: Point(0, 0),
          end: Point(5, 5),
          type: Surface());
      expect(t.name, equals('Test tile'));
      expect(t.start, equals(Point<int>(0, 0)));
      expect(t.end, equals(Point<int>(5, 5)));
      expect(t.type is Surface, isTrue);
      expect(t.type.minMoveInterval, equals(500));
    });

    test('Custom tile tests', () {
      final t = CustomTile();
      expect(
          t.onActivate,
          throwsA(predicate(
              (e) => e is ActivateException && e.message == 'Activate')));
    });
  });
}
