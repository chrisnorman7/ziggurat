/// Ziggurat tests.
import 'dart:io';
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

/// Pretend quest states.
enum QuestStates {
  /// Quest hasn't been started.
  notStarted,

  /// Quest has been accepted.
  accepted,

  /// First item has been found.
  firstItemFound,

  /// The quest has been completed.
  completed,
}

/// A test.
class TestQuest extends Quest<QuestStates> {
  const TestQuest() : super(QuestStates.notStarted);

  /// Get a string representation of the state.
  @override
  String getStateString(QuestStates state) {
    switch (state) {
      case QuestStates.notStarted:
        return 'Not started';
      case QuestStates.accepted:
        return 'Find the test item';
      case QuestStates.firstItemFound:
        return 'Find the second test item';
      case QuestStates.completed:
        return 'Completed';
    }
  }
}

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
  CustomTile()
      : super('Custom Tile', Point<int>(0, 0), Point<int>(5, 5), Surface());

  /// Throw an error when this tile is activated.
  @override
  void onActivate() {
    throw ActivateException('Activate');
  }
}

/// Imaginary game state.
class GameState {}

void main() {
  // Initialise synthizer.
  final synthizer = Synthizer()..initialize();
  final bufferCache = BufferCache(synthizer, pow(1024, 3).floor());
  final ctx = synthizer.createContext();
  // Test ambiances.
  group('Ambiance tests', () {
    test('Initialisation', () {
      final a = Ambiance(File('sound.wav'), Point<double>(5.0, 4.0));
      expect(a.path.path, equals('sound.wav'));
      expect(a.position, equals(Point<double>(5.0, 4.0)));
    });
  });

  // Test random sounds.
  group('Random sounds tests', () {
    test('Initialisation', () {
      final r = RandomSound(File('sound.wav'), Point(0, 1), Point(5, 6), 15, 30,
          minGain: 0.1, maxGain: 1.0);
      expect(r.path.path, equals('sound.wav'));
      expect(r.minCoordinates.x, equals(0));
      expect(r.maxCoordinates.x, equals(5));
      expect(r.minCoordinates.y, equals(1));
      expect(r.maxCoordinates.y, equals(6));
      expect(r.minInterval, equals(15));
      expect(r.maxInterval, equals(30));
      expect(r.minGain, equals(0.1));
      expect(r.maxGain, equals(1.0));
    });
  });

  // Test tiles.
  group('Tiles tests', () {
    test('Initialisation', () {
      final t =
          Tile('Test tile', Point<int>(0, 0), Point<int>(5, 5), Surface());
      expect(t.name, equals('Test tile'));
      expect(t.start, equals(Point<int>(0, 0)));
      expect(t.end, equals(Point<int>(5, 5)));
      expect(t.type is Surface, isTrue);
      expect(t.type.walkInterval, equals(0.5));
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
      var w = Tile<Wall>('Wall', Point<int>(0, 0), Point<int>(5, 0), Wall());
      expect(w.start, equals(Point<int>(0, 0)));
      expect(w.end, equals(Point<int>(5, 0)));
      expect(w.type is Wall, isTrue);
      expect(w.type.surmountable, isFalse);
      w = Tile<Wall>('Wall 2', w.start, w.end, Wall(surmountable: true));
      expect(w.type.surmountable, isTrue);
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
    });
  });
  group('Quests test', () {
    final TestQuest q = TestQuest();
    test('Initialisation test', () {
      expect(q.defaultState, equals(QuestStates.notStarted));
    });
    test('getStateString tests', () {
      expect(q.getStateString(QuestStates.notStarted), equals('Not started'));
      expect(q.getStateString(QuestStates.completed), equals('Completed'));
    });
  });
  group('Runner tests', () {
    final r = Runner<GameState>(ctx, bufferCache, GameState());
    test('Initialisation', () {
      expect(r.ziggurat, isNull);
      expect(r.context, equals(ctx));
      expect(r.coordinates, equals(Point<double>(0.0, 0.0)));
    });
  });
  group('Game State Tests', () {
    final r = Runner(ctx, bufferCache, GameState());
    test('Check game state', () {
      expect(r.gameState, isA<GameState>());
    });
  });
}
