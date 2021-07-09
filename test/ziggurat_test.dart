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
class CustomTile extends Tile {
  /// Create an instance.
  CustomTile() : super('Custom Tile', Point<int>(0, 0), Point<int>(5, 5));

  /// Throw an error when this tile is activated.
  @override
  void onActivate() {
    throw ActivateException('Activate');
  }
}

void main() {
  // Test ambiances.
  group('Ambiance tests', () {
    test('Initialisation', () {
      final a = Ambiance('sound.wav', Point<int>(5, 4));
      expect(a.path, equals('sound.wav'));
      expect(a.position, equals(Point<int>(5, 4)));
    });
  });

  // Test random sounds.
  group('Random sounds tests', () {
    test('Initialisation', () {
      final r = RandomSound('sound.wav', 0, 1, 5, 6, 15, 30,
          minGain: 0.1, maxGain: 1.0);
      expect(r.path, equals('sound.wav'));
      expect(r.minX, equals(0));
      expect(r.maxX, equals(5));
      expect(r.minY, equals(1));
      expect(r.maxY, equals(6));
      expect(r.minInterval, equals(15));
      expect(r.maxInterval, equals(30));
      expect(r.minGain, equals(0.1));
      expect(r.maxGain, equals(1.0));
    });
  });

  // Test tiles.
  group('Tiles tests', () {
    test('Initialisation', () {
      final t = Tile('Test tile', Point<int>(0, 0), Point<int>(5, 5));
      expect(t.name, equals('Test tile'));
      expect(t.start, equals(Point<int>(0, 0)));
      expect(t.end, equals(Point<int>(5, 5)));
    });

    test('Custom tile tests', () {
      final t = CustomTile();
      expect(
          t.onActivate,
          throwsA(predicate(
              (e) => e is ActivateException && e.message == 'Activate')));
    });
  });

  // Test walls.
  group('Walls tests', () {
    test('Initialisation', () {
      var w = Wall(Point<int>(0, 0), Point<int>(5, 0));
      expect(w.start, equals(Point<int>(0, 0)));
      expect(w.end, equals(Point<int>(5, 0)));
      expect(w.surmountable, isFalse);
      w = Wall(w.start, w.end, surmountable: true);
      expect(w.surmountable, isTrue);
    });
  });

  // Test ziggurats.
  group('Ziggurat tests', () {
    test('Initialisation', () {
      final z = Ziggurat('Test');
      expect(z.name, equals('Test'));
      expect(z.ambiances, isEmpty);
      expect(z.initialCoordinates, equals(Point<int>(0, 0)));
      expect(z.randomSounds, isEmpty);
      expect(z.tiles, isEmpty);
      expect(z.walls, isEmpty);
    });
  });
}
