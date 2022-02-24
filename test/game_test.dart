import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

import 'helpers.dart';

class TestLevel extends Level {
  /// Create.
  TestLevel(Game game)
      : lastTicked = 0,
        super(game: game);

  /// The number of milliseconds since the [game] ticked.
  int lastTicked;
  @override
  void tick(Sdl sdl, int timeDelta) {
    lastTicked = timeDelta;
    super.tick(sdl, timeDelta);
  }
}

void main() {
  group('Game tests', () {
    test('Initialization', () {
      final game = Game('Test Game');
      expect(game.title, equals('Test Game'));
      expect(game.currentLevel, isNull);
      expect(game.triggerMap.triggers, equals(<CommandTrigger>[]));
    });
    test('Current Level', () {
      final game = Game('Test Game');
      final level1 = Level(game: game);
      game.pushLevel(level1);
      expect(game.currentLevel, equals(level1));
      final level2 = Level(game: game);
      game.pushLevel(level2);
      expect(game.currentLevel, equals(level2));
    });
    test('One-off Task Test', () async {
      final sdl = Sdl();
      final game = Game('Test Game');
      var i = 0;
      final task = Task(runAfter: 3, func: () => i++);
      game.registerTask(task);
      expect(game.tasks.length, 1);
      final runner = game.tasks.first;
      expect(runner.numberOfRuns, isZero);
      expect(runner.value, task);
      expect(runner.runAfter, isZero);
      expect(task.runAfter, equals(3));
      expect(i, isZero);
      for (var j = 1; j < task.runAfter; j++) {
        await game.tick(sdl, 1);
        expect(i, isZero);
        expect(runner.numberOfRuns, isZero);
        expect(runner.runAfter, j);
      }
      game.tick(sdl, 1);
      expect(i, equals(1));
      expect(game.tasks, isEmpty);
    });
    test('Repeating Task Test', () async {
      final sdl = Sdl();
      final game = Game('Test Game');
      var i = 0;
      final task = Task(runAfter: 3, func: () => i++, interval: 2);
      expect(task.interval, equals(2));
      expect(task.runAfter, equals(3));
      game.registerTask(task);
      expect(game.tasks.length, 1);
      expect(i, isZero);
      final runner = game.tasks.first;
      expect(runner.numberOfRuns, isZero);
      expect(runner.value, task);
      expect(runner.runAfter, isZero);
      for (var j = 1; j < task.runAfter; j++) {
        await game.tick(sdl, 1);
        expect(i, equals(0));
        expect(runner.runAfter, j);
      }
      await game.tick(sdl, 1);
      expect(i, equals(1));
      expect(game.tasks, isNotEmpty);
      expect(game.tasks.first, runner);
      await game.tick(sdl, 1);
      expect(i, equals(1));
      await game.tick(sdl, 1);
      expect(i, equals(2));
      expect(game.tasks.length, equals(1));
      expect(game.tasks.first, runner);
    });
    test('.registerTask', () {
      final sdl = Sdl();
      final game = Game('Tasks that add tasks');
      expect(game.tasks, isEmpty);
      game.registerTask(
        Task(
          runAfter: 0,
          func: () => game.callAfter(runAfter: 0, func: game.stop),
        ),
      );
      expect(game.tasks.length, equals(1));
      game.tick(sdl, 0);
      expect(game.tasks.length, equals(1));
      expect(game.tasks.first.value.func, equals(game.stop));
    });
    test(
      '.callAfter',
      () {
        final game = Game('Test callAfter');
        var i = 0;
        final task = game.callAfter(func: () => i++, runAfter: 15);
        expect(task, isA<Task>());
        expect(task.interval, isNull);
        expect(task.runAfter, 15);
        expect(game.tasks.length, 1);
        var runner = game.tasks.first;
        expect(runner.value, task);
        final sdl = Sdl();
        game.tick(sdl, 14);
        expect(game.tasks.length, 1);
        runner = game.tasks.first;
        expect(runner.numberOfRuns, isZero);
        expect(runner.value, task);
        expect(runner.runAfter, 14);
        game.tick(sdl, 1);
        expect(game.tasks, isEmpty);
        expect(runner.numberOfRuns, 1);
        expect(runner.value, task);
        expect(runner.runAfter, isZero);
      },
    );
    test('.unregisterTask', () {
      final game = Game('unregisterTask');
      final task = Task(runAfter: 1234, func: game.stop);
      game.registerTask(task);
      expect(game.tasks.length, equals(1));
      game.unregisterTask(
        Task(
          func: () => game.callAfter(runAfter: 200, func: game.stop),
          runAfter: task.runAfter,
        ),
      );
      expect(game.tasks.length, equals(1));
      game.unregisterTask(task);
      expect(game.tasks, isEmpty);
    });
    test('replaceLevel', () {
      final game = Game('Replace Level');
      final level1 = Level(game: game);
      final level2 = Level(game: game);
      game
        ..pushLevel(level1)
        ..replaceLevel(level2);
      expect(game.currentLevel, equals(level2));
      game.popLevel();
      expect(game.currentLevel, isNull);
      game
        ..pushLevel(level1)
        ..replaceLevel(level2, ambianceFadeTime: 2.0);
      expect(game.currentLevel, isNull);
      expect(game.tasks.length, equals(1));
      final runner = game.tasks.first;
      expect(runner.value.runAfter, equals(2000));
    });
    test('.tick', () {
      final sdl = Sdl();
      final game = Game('Game.tick');
      final level = TestLevel(game);
      game.tick(sdl, 1);
      expect(level.lastTicked, isZero);
      game
        ..pushLevel(level)
        ..tick(sdl, 1234);
      expect(level.lastTicked, equals(1234));
      game
        ..popLevel()
        ..tick(sdl, 9876);
      expect(level.lastTicked, equals(1234));
    });
    test('.pushLevel', () async {
      final game = Game('Game.pushLevel');
      final sdl = Sdl();
      final level1 = Level(game: game);
      final level2 = Level(game: game);
      game.pushLevel(level1);
      expect(game.currentLevel, equals(level1));
      expect(game.tasks, isEmpty);
      await game.tick(sdl, 1);
      expect(game.currentLevel, equals(level1));
      expect(game.tasks, isEmpty);
      game.pushLevel(level2, after: 400);
      expect(game.currentLevel, equals(level1));
      expect(game.tasks.length, equals(1));
      await game.tick(sdl, 399);
      expect(game.currentLevel, equals(level1));
      expect(game.tasks.length, equals(1));
      await game.tick(sdl, 1);
      expect(game.currentLevel, equals(level2));
      expect(game.tasks, isEmpty);
    });
    test('.pushLevel with `after`', () async {
      final sdl = Sdl();
      final game = Game('Game.pushLevel');
      final level = Level(game: game);
      game.pushLevel(level, after: 200);
      expect(game.currentLevel, isNull);
      expect(game.tasks.length, equals(1));
      var runner = game.tasks.first;
      expect(runner.numberOfRuns, isZero);
      expect(runner.runAfter, isZero);
      await game.tick(sdl, 200);
      expect(game.currentLevel, equals(level));
      expect(runner.numberOfRuns, 1);
      expect(runner.runAfter, isZero);
      expect(game.tasks, isEmpty);
      game.popLevel();
      expect(game.currentLevel, isNull);
      game.pushLevel(level, after: 400);
      expect(game.currentLevel, isNull);
      expect(game.tasks.length, equals(1));
      runner = game.tasks.first;
      expect(runner.numberOfRuns, isZero);
      expect(runner.value.runAfter, 400);
      expect(runner.runAfter, isZero);
      await game.tick(sdl, 0);
      expect(game.currentLevel, isNull);
      expect(game.tasks.length, equals(1));
      expect(game.tasks, contains(runner));
      expect(runner.numberOfRuns, isZero);
      expect(runner.runAfter, isZero);
      await game.tick(sdl, 399);
      expect(game.currentLevel, isNull);
      expect(game.tasks.length, equals(1));
      expect(game.tasks, contains(runner));
      expect(runner.numberOfRuns, isZero);
      expect(runner.runAfter, 399);
      await game.tick(sdl, 1);
      expect(game.currentLevel, equals(level));
      expect(game.tasks, isEmpty);
      expect(runner.numberOfRuns, 1);
      expect(runner.runAfter, isZero);
    });
    test('Random sounds', () async {
      final sdl = Sdl();
      final game = Game('Play Random Sounds');
      final randomSound1 = RandomSound(
        sound: AssetReference.file('sound1.wav'),
        minCoordinates: Point(1.0, 2.0),
        maxCoordinates: Point(5.0, 6.0),
        minInterval: 1000,
        maxInterval: 1000,
      );
      final randomSound2 = RandomSound(
        sound: AssetReference.file('sound2.wav'),
        minCoordinates: Point(23.0, 24.0),
        maxCoordinates: Point(38.0, 39.0),
        minInterval: 2000,
        maxInterval: 10000,
        minGain: 0.1,
        maxGain: 1.0,
      );
      final l = Level(game: game, randomSounds: [randomSound1, randomSound2]);
      game.pushLevel(l);
      expect(l.randomSoundPlaybacks[randomSound1], isNull);
      expect(l.randomSoundPlaybacks[randomSound2], isNull);
      expect(l.getRandomSoundNextPlay(randomSound1).runAfter,
          randomSound1.minInterval);
      expect(
        l.getRandomSoundNextPlay(randomSound2).runAfter,
        inOpenClosedRange(randomSound2.minInterval, randomSound2.maxInterval),
      );
      await game.tick(sdl, 0);
      final randomSound1NextPlay = l.getRandomSoundNextPlay(randomSound1);
      expect(randomSound1NextPlay.runAfter, randomSound1.minInterval);
      final randomSound2NextPlay = l.getRandomSoundNextPlay(randomSound2);
      expect(
        randomSound2NextPlay.runAfter,
        inOpenClosedRange(randomSound2.minInterval, randomSound2.maxInterval),
      );
      await game.tick(sdl, randomSound1NextPlay.runAfter);
      expect(randomSound1NextPlay.runAfter, isZero);
      expect(randomSound2NextPlay.runAfter, greaterThan(0));
      await game.tick(sdl, 1);
      expect(randomSound1NextPlay.runAfter, randomSound1.minInterval);
      expect(l.randomSoundPlaybacks.length, 1);
      expect(l.randomSoundPlaybacks[randomSound1], isNotNull);
      expect(l.randomSoundPlaybacks[randomSound2], isNull);
      var playback = l.randomSoundPlaybacks[randomSound1]!;
      expect(playback.sound.gain, equals(randomSound1.minGain));
      expect(playback.channel.position, isA<SoundPosition3d>());
      var position = playback.channel.position as SoundPosition3d;
      expect(
        position.x,
        inOpenClosedRange(
          randomSound1.minCoordinates.x,
          randomSound1.maxCoordinates.x,
        ),
      );
      expect(
        position.y,
        inOpenClosedRange(
          randomSound1.minCoordinates.y,
          randomSound1.maxCoordinates.y,
        ),
      );
      expect(position.z, isZero);
      await game.tick(sdl, randomSound2NextPlay.runAfter);
      expect(randomSound2NextPlay.runAfter, isZero);
      await game.tick(sdl, 1);
      expect(
        randomSound2NextPlay.runAfter,
        inOpenClosedRange(randomSound2.minInterval, randomSound2.maxInterval),
      );
      expect(l.randomSoundPlaybacks[randomSound2], isNotNull);
      playback = l.randomSoundPlaybacks[randomSound2]!;
      expect(playback.sound.gain,
          inOpenClosedRange(randomSound2.minGain, randomSound2.maxGain));
      expect(playback.channel.position, isA<SoundPosition3d>());
      position = playback.channel.position as SoundPosition3d;
      expect(
          position.x,
          inOpenClosedRange(
              randomSound2.minCoordinates.x, randomSound2.maxCoordinates.x));
      expect(
          position.y,
          inOpenClosedRange(
              randomSound2.minCoordinates.y, randomSound2.maxCoordinates.y));
      expect(position.z, isZero);
      expect(
        l.getRandomSoundNextPlay(randomSound2).runAfter,
        inOpenClosedRange(randomSound2.minInterval, randomSound2.maxInterval),
      );
    });
    test('Commands returning', () {
      final trigger1 = CommandTrigger(
        name: 'command1',
        description: 'First command',
      );
      final trigger2 = CommandTrigger(
        name: 'command2',
        description: 'Second command',
      );
      final game = Game(
        'Commands',
        triggerMap: TriggerMap(
          [trigger1, trigger2],
        ),
      );
      final level = Level(
        game: game,
        commands: {trigger1.name: Command(), trigger2.name: Command()},
      );
      expect(level.startCommand(trigger1.name), isTrue);
      expect(level.startCommand(trigger2.name), isTrue);
      expect(level.stopCommand(trigger1.name), isTrue);
      expect(level.stopCommand(trigger2.name), isTrue);
      expect(level.startCommand('testing'), isFalse);
      expect(level.stopCommand('testing'), isFalse);
    });
    test(
      'Shadowed commands',
      () {
        final trigger1 = CommandTrigger(
          name: 'command1',
          description: 'First command',
          keyboardKey:
              CommandKeyboardKey(ScanCode.SCANCODE_RIGHT, altKey: true),
        );
        final trigger2 = CommandTrigger(
          name: 'command2',
          description: 'Second command',
          keyboardKey: CommandKeyboardKey(trigger1.keyboardKey!.scanCode),
        );
        final game = Game(
          'Testing',
          triggerMap: TriggerMap(
            [trigger1, trigger2],
          ),
        );
        final list = <int>[];
        final level = Level(
          game: game,
          commands: {
            trigger1.name: Command(
              onStart: () => list.add(1),
            ),
            trigger2.name: Command(
              onStart: () => list.add(2),
            ),
          },
        );
        game.pushLevel(level);
        expect(list, isEmpty);
        final sdl = Sdl();
        game.handleSdlEvent(
          makeKeyboardEvent(
            sdl,
            trigger1.keyboardKey!.scanCode,
            KeyCode.keycode_0,
            modifiers: [KeyMod.alt],
            state: PressedState.pressed,
          ),
        );
        expect(list.length, 1);
        expect(list.first, 1);
        game.handleSdlEvent(
          makeKeyboardEvent(
            sdl,
            trigger1.keyboardKey!.scanCode,
            KeyCode.keycode_0,
            state: PressedState.pressed,
          ),
        );
        expect(list.length, 2);
        expect(list, [1, 2]);
      },
    );
  });
}
