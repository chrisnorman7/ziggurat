import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

/// Custom level.
class CustomLevel extends Level {
  /// Create a custom level.
  CustomLevel(Game game) : super(game);

  /// Whether or not this level has been pushed.
  bool wasPushed = false;

  /// Whether or not this level has been popped.
  bool wasPopped = false;

  /// Any level that covered this level.
  Level? wasCovered;

  /// Any level that has revealed this level.
  Level? wasRevealed;

  /// This level was pushed.
  @override
  void onPush() {
    super.onPush();
    wasPushed = true;
  }

  /// This level was popped.
  @override
  void onPop(double? ambianceFadeLength) {
    super.onPop(ambianceFadeLength);
    wasPopped = true;
  }

  /// This level was covered.
  @override
  void onCover(Level newLevel) {
    wasCovered = newLevel;
  }

  /// This level was revealed.
  @override
  void onReveal(Level revealingLevel) {
    wasRevealed = revealingLevel;
  }
}

/// A level with commands.
class CommandLevel extends Level {
  /// Create a level.
  CommandLevel(Game game)
      : started = false,
        stopped = false,
        super(game) {
    registerCommand('testCommand',
        Command(onStart: () => started = true, onStop: () => stopped = true));
  }

  /// The command was started.
  bool started;

  /// The command was stopped.
  bool stopped;
}

/// A level with an increment command.
class IncrementLevel extends Level {
  /// Create a level.
  IncrementLevel(Game game)
      : counter = 0,
        super(game) {
    registerCommand(
        'increment', Command(onStart: () => counter++, interval: 500));
  }

  /// The number of increments.
  int counter;
}

void main() {
  group('Level Tests', () {
    test('Test Initialisation', () {
      final game = Game('Test Game');
      final level = Level(game);
      expect(level.game, equals(game));
      expect(level.commands, equals(<String, Command>{}));
    });
    test('Register Commands', () {
      final game = Game('Test Game');
      final level = Level(game);
      final command = Command();
      level.registerCommand('testing', command);
      expect(level.commands, equals({'testing': command}));
    });
  });
  group('Custom Levels', () {
    test('Initialisation', () {
      final game = Game('Test game');
      final level = CustomLevel(game);
      expect(level.game, equals(game));
      expect(level.wasPushed, isFalse);
      expect(level.wasPopped, isFalse);
      expect(level.wasCovered, isNull);
      expect(level.wasRevealed, isNull);
    });
  });
  group('Level Tests', () {
    test('Push Level', () {
      final game = Game('Test Game');
      final level1 = CustomLevel(game);
      game.pushLevel(level1);
      expect(game.currentLevel, equals(level1));
      expect(level1.wasPushed, isTrue);
      expect(level1.wasPopped, isFalse);
      expect(level1.wasCovered, isNull);
      expect(level1.wasRevealed, isNull);
      final level2 = CustomLevel(game);
      game.pushLevel(level2);
      expect(game.currentLevel, equals(level2));
      expect(level2.wasPushed, isTrue);
      expect(level2.wasPopped, isFalse);
      expect(level2.wasCovered, isNull);
      expect(level2.wasRevealed, isNull);
      expect(level1.wasCovered, equals(level2));
      expect(game.popLevel(), equals(level2));
      expect(level2.wasPopped, isTrue);
      expect(game.currentLevel, equals(level1));
      expect(level1.wasRevealed, equals(level2));
    });
    test('Command Tests', () {
      final game = Game('Test Game');
      final level = CommandLevel(game);
      expect(level.started, isFalse);
      expect(level.stopped, isFalse);
      level.startCommand('invalidCommand');
      expect(level.started, isFalse);
      expect(level.stopped, isFalse);
      level.stopCommand('invalidCommand');
      expect(level.started, isFalse);
      expect(level.stopped, isFalse);
      level.startCommand('testCommand');
      expect(level.started, isTrue);
      expect(level.stopped, isFalse);
      level.stopCommand('testCommand');
      expect(level.started, isTrue);
      expect(level.stopped, isTrue);
    });
    test('Start Command Tests', () {
      final game = Game('Test Game');
      final level = IncrementLevel(game);
      final command = level.commands['increment'];
      expect(command, isA<Command>());
      expect(level.counter, equals(0));
      game.time = DateTime.now().millisecondsSinceEpoch;
      level.startCommand('increment');
      expect(level.counter, equals(1));
      expect(command!.nextRun, equals(game.time + 500));
      level.startCommand('increment');
      expect(level.counter, equals(1));
      expect(command.nextRun, equals(game.time + 500));
      game.time += 500;
      level.startCommand('increment');
      expect(level.counter, equals(2));
      expect(command.nextRun, equals(game.time + 500));
    });
    test('Ambiances', () {
      final game = Game('Level Ambiances');
      final ambiance1 =
          Ambiance(sound: AssetReference.file('sound1'), gain: 0.1);
      final ambiance2 = Ambiance(
          sound: AssetReference.collection('sound2'),
          gain: 0.2,
          position: Point(5.0, 6.0));
      final level = Level(game, ambiances: [ambiance1, ambiance2]);
      game.pushLevel(level);
      expect(ambiance1.playback, isNotNull);
      expect(ambiance2.playback, isNotNull);
      expect(
          ambiance1.playback?.sound,
          predicate((value) =>
              value is PlaySound &&
              value.sound == ambiance1.sound &&
              value.gain == ambiance1.gain &&
              value.keepAlive == true));
      expect(ambiance1.playback?.channel, equals(game.ambianceSounds));
      expect(
          ambiance2.playback?.channel,
          predicate((value) =>
              value is SoundChannel && value.position is SoundPosition3d));
      final position = ambiance2.playback!.channel.position as SoundPosition3d;
      expect(position.x, equals(ambiance2.position!.x));
      expect(position.y, equals(ambiance2.position!.y));
      expect(position.z, isZero);
      expect(
          ambiance2.playback?.sound,
          predicate((value) =>
              value is PlaySound &&
              value.sound == ambiance2.sound &&
              value.gain == ambiance2.gain &&
              value.keepAlive == true));
    });
  });
}