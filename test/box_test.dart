//// Test boxes.
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

/// The error which should be thrown by [CustomTile.onActivate].
class ActivateException implements Exception {
  /// Create an exception.
  ActivateException(this.message);

  /// The message.
  final String message;
}

/// A custom tile.
class CustomTile extends Box {
  /// Create an instance.
  CustomTile() : super('Custom Tile', Point(0, 0), Point(5, 5), Surface());

  /// Throw an error when this tile is activated.
  @override
  void onActivate() {
    throw ActivateException('Activate');
  }
}

void main() {
  group('boxes tests', () {
    test('Initialisation', () {
      final t = Box('Test tile', Point(0, 0), Point(5, 5), Surface());
      expect(t.name, equals('Test tile'));
      expect(t.start, equals(Point<int>(0, 0)));
      expect(t.end, equals(Point<int>(5, 5)));
      expect(t.type is Surface, isTrue);
      expect(t.type.moveInterval, equals(500));
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
