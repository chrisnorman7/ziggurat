/// Test the [Runner] class.
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

/// Imaginary game state.
class GameState {}

void main() {
  final synthizer = Synthizer();
  final sdl = Sdl();
  group('Tests requiring Synthizer', () {
    setUpAll(synthizer.initialize);
    tearDownAll(synthizer.shutdown);
    final bufferStore = BufferStore(Random(), synthizer);
    late EventLoop<GameState> eventLoop;
    late Runner r;
    setUp(() {
      final ctx = synthizer.createContext();
      eventLoop = EventLoop(
          context: ctx,
          bufferStore: bufferStore,
          sdl: sdl,
          commandHandler: CommandHandler(),
          gameState: GameState());
      r = Runner(eventLoop, Box('Player', Point(0, 0), Point(0, 0), Player()));
    });
    tearDown(() {
      r.stop();
      r.eventLoop.context.destroy();
    });
    test('Initialisation', () {
      expect(r.ziggurat, isNull);
      expect(r.eventLoop, isA<EventLoop>());
      expect(r.eventLoop.context, isA<Context>());
      expect(r.coordinates, equals(Point<double>(0.0, 0.0)));
      expect(r.eventLoop.gameState, isA<GameState>());
    });
    test('Check game state', () {});
  });
}
