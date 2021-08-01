/// Test the [Runner] class.
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

/// Imaginary game state.
class GameState {}

void main() {
  final synthizer = Synthizer();
  group('Tests requiring Synthizer', () {
    setUpAll(synthizer.initialize);
    tearDownAll(synthizer.shutdown);
    final bufferCache = BufferCache(synthizer, pow(1024, 3).floor());
    late Runner<GameState> r;
    setUp(() {
      final ctx = synthizer.createContext();
      r = Runner<GameState>(ctx, bufferCache, GameState(),
          Box('Player', Point(0, 0), Point(0, 0), Player()));
    });
    tearDown(() {
      r.stop();
      r.context.destroy();
    });
    test('Initialisation', () {
      expect(r.ziggurat, isNull);
      expect(r.context, isA<Context>());
      expect(r.coordinates, equals(Point<double>(0.0, 0.0)));
    });
    test('Check game state', () {
      expect(r.gameState, isA<GameState>());
    });
  });
}
