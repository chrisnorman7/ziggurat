/// Test the [Runner] class.
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

/// Imaginary game state.
class GameState {}

void main() {
  group('Tests requiring Synthizer', () {
    final synthizer = Synthizer()..initialize();
    final ctx = Context(synthizer);
    final bufferCache = BufferCache(synthizer, pow(1024, 3).floor());
    late Runner<GameState> r;
    setUp(() {
      r = Runner<GameState>(ctx, bufferCache, GameState());
    });
    test('Initialisation', () {
      expect(r.ziggurat, isNull);
      expect(r.context, equals(ctx));
      expect(r.coordinates, equals(Point<double>(0.0, 0.0)));
    });
    test('Check game state', () {
      expect(r.gameState, isA<GameState>());
    });
  });
}
