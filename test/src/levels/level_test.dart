import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:dart_sdl/src/sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

const incrementCommandName = 'increment';

/// Custom level.
class CustomLevel extends Level {
  /// Create a custom level.
  CustomLevel(final Game game) : super(game: game);

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
  void onPush({final double? fadeLength}) {
    super.onPush(fadeLength: fadeLength);
    wasPushed = true;
  }

  /// This level was popped.
  @override
  void onPop(final double? ambianceFadeLength) {
    super.onPop(ambianceFadeLength);
    wasPopped = true;
  }

  /// This level was covered.
  @override
  void onCover(final Level newLevel) {
    wasCovered = newLevel;
  }

  /// This level was revealed.
  @override
  void onReveal(final Level revealingLevel) {
    wasRevealed = revealingLevel;
  }
}

/// A level with commands.
class CommandLevel extends Level {
  /// Create a level.
  CommandLevel(final Game game)
      : started = false,
        stopped = false,
        super(game: game) {
    registerCommand(
      'testCommand',
      Command(onStart: () => started = true, onStop: () => stopped = true),
    );
  }

  /// The command was started.
  bool started;

  /// The command was stopped.
  bool stopped;
}

/// A level with an increment command.
class IncrementLevel extends Level {
  /// Create a level.
  IncrementLevel(final Game game)
      : counter = 0,
        super(game: game) {
    registerCommand(
      incrementCommandName,
      Command(onStart: () => counter++, interval: 500),
    );
  }

  /// The number of increments.
  int counter;
}

void main() {
  final sdl = Sdl();
  group('Level Tests', () {
    test('Test Initialisation', () {
      final game = Game(
        title: 'Test Game',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      final level = Level(game: game);
      expect(level.game, equals(game));
      expect(level.commands, equals(<String, Command>{}));
    });
    test('Register Commands', () {
      final game = Game(
        title: 'Test Game',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      final level = Level(game: game);
      const command = Command();
      level.registerCommand('testing', command);
      expect(level.commands, equals({'testing': command}));
    });
    test('Push Level', () {
      final game = Game(
        title: 'Test Game',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
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
      final game = Game(
        title: 'Test Game',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
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
    test('Start Command Tests', () async {
      final game = Game(
        title: 'Test Game',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      final level = IncrementLevel(game);
      game.pushLevel(level);
      final command = level.commands[incrementCommandName]!;
      expect(command, isA<Command>());
      expect(command.interval, 500);
      expect(
        level.commandNextRuns.where(
          (final element) => element.value == command,
        ),
        isEmpty,
      );
      expect(level.getCommandNextRun(command), isNull);
      expect(level.counter, isZero);
      level.startCommand(incrementCommandName);
      expect(
        level.commandNextRuns.where(
          (final element) => element.value == command,
        ),
        isNotEmpty,
      );
      final nextRun = level.getCommandNextRun(command)!;
      expect(nextRun.runAfter, isZero);
      expect(level.counter, 1);
      level.startCommand(incrementCommandName);
      expect(level.counter, 1);
      expect(level.getCommandNextRun(command)?.runAfter, isZero);
      level.startCommand('increment');
      expect(level.counter, 1);
      expect(level.getCommandNextRun(command)?.runAfter, 0);
      await game.tick(1);
      expect(level.getCommandNextRun(command)?.runAfter, 1);
      await game.tick(498);
      expect(level.counter, 1);
      expect(level.getCommandNextRun(command)?.runAfter, 499);
      await game.tick(1);
      expect(level.counter, 2);
      expect(level.getCommandNextRun(command)?.runAfter, isZero);
    });
    test('Ambiances', () {
      final game = Game(
        title: 'Level Ambiances',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      const ambiance1 = Ambiance(
        sound: AssetReference.file('sound1'),
        gain: 0.1,
      );
      const ambiance2 = Ambiance(
        sound: AssetReference.collection('sound2'),
        gain: 0.2,
        position: Point(5.0, 6.0),
      );
      final level = Level(game: game, ambiances: [ambiance1, ambiance2]);
      game.pushLevel(level);
      final ambiance1Playback = level.ambiancePlaybacks[ambiance1];
      final ambiance2Playback = level.ambiancePlaybacks[ambiance2];
      expect(ambiance1Playback, isNotNull);
      expect(ambiance2Playback, isNotNull);
      expect(
        ambiance1Playback?.sound,
        predicate(
          (final value) =>
              value is Sound &&
              value.channel == game.ambianceSounds &&
              value.gain == ambiance1.gain &&
              value.keepAlive == true,
        ),
      );
      expect(ambiance1Playback?.channel, equals(game.ambianceSounds));
      expect(
        ambiance2Playback?.channel,
        isNotNull,
      );
      final ambiance2Channel = ambiance2Playback!.channel;
      expect(ambiance2Channel.position, isA<SoundPosition3d>());
      final position = ambiance2Playback.channel.position as SoundPosition3d;
      expect(position.x, equals(ambiance2.position!.x));
      expect(position.y, equals(ambiance2.position!.y));
      expect(position.z, isZero);
      expect(
        ambiance2Playback.sound,
        predicate(
          (final value) =>
              value is Sound &&
              value.channel == ambiance2Channel &&
              value.gain == ambiance2.gain &&
              value.keepAlive == true,
        ),
      );
    });
    test('music', () {
      final game = Game(
        title: 'Music Test',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      const music = Music(
        sound: AssetReference.file('music.mp3'),
        gain: 1.0,
      );
      final level = Level(
        game: game,
        music: music,
      );
      expect(level.musicSound, isNull);
      game.pushLevel(level);
      final sound = level.musicSound!;
      expect(sound.channel, game.musicSounds);
      expect(sound.gain, music.gain);
      expect(sound.keepAlive, isTrue);
      expect(sound.looping, isTrue);
      game.popLevel();
      expect(level.musicSound, isNull);
    });
    test('.stoppedCommands', () async {
      final commandTrigger = CommandTrigger.basic(
        name: 'increase',
        description: 'Increase `i`',
      );
      final game = Game(
        title: 'Level.stoppedCommands',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
        triggerMap: TriggerMap([commandTrigger]),
      );
      final level = Level(game: game);
      expect(level.stoppedCommands, isEmpty);
      var i = 0;
      const interval = 200;
      final command = Command(
        onStart: () => i += 1,
        interval: interval,
      );
      level.registerCommand(commandTrigger.name, command);
      game.pushLevel(level);
      expect(i, isZero);
      expect(level.commandNextRuns, isEmpty);
      expect(level.stoppedCommands, isEmpty);
      level.startCommand(commandTrigger.name);
      expect(i, 1);
      expect(level.commandNextRuns.length, 1);
      final nextRun = level.commandNextRuns.first;
      expect(nextRun.value, command);
      expect(nextRun.value.interval, interval);
      expect(level.getCommandNextRun(command), nextRun);
      await game.tick(interval - 1);
      expect(nextRun.runAfter, interval - 1);
      await game.tick(2);
      expect(i, 2);
      expect(nextRun.runAfter, 1);
      level.stopCommand(commandTrigger.name);
      expect(i, 2);
      expect(level.commandNextRuns, isEmpty);
      expect(level.stoppedCommands.length, 1);
      expect(identical(level.stoppedCommands.first, nextRun), isTrue);
      expect(nextRun.runAfter, 1);
      await game.tick(40);
      expect(i, 2);
      expect(level.stoppedCommands.length, 1);
      expect(level.stoppedCommands.first, nextRun);
      expect(nextRun.runAfter, 41);
      await game.tick(command.interval!);
      expect(level.stoppedCommands, isEmpty);
      expect(level.commandNextRuns, isEmpty);
    });
  });
  group('Custom Levels', () {
    test('Initialisation', () {
      final game = Game(
        title: 'Test game',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      final level = CustomLevel(game);
      expect(level.game, equals(game));
      expect(level.wasPushed, isFalse);
      expect(level.wasPopped, isFalse);
      expect(level.wasCovered, isNull);
      expect(level.wasRevealed, isNull);
    });
  });
}
