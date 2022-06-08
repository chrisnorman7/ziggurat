import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

import 'helpers.dart';

class TestLevel extends Level {
  /// Create.
  TestLevel(final Game game)
      : lastTicked = 0,
        super(game: game);

  /// The number of milliseconds since the [game] ticked.
  int lastTicked;
  @override
  void tick(final Sdl sdl, final int timeDelta) {
    lastTicked = timeDelta;
    super.tick(sdl, timeDelta);
  }
}

void main() {
  final sdl = Sdl();
  group('Game tests', () {
    test('Initialization', () {
      final game = Game(
        title: 'Test Game',
        sdl: sdl,
      );
      expect(game.title, equals('Test Game'));
      expect(game.currentLevel, isNull);
      expect(game.triggerMap.triggers, equals(<CommandTrigger>[]));
    });
    test('Current Level', () {
      final game = Game(
        title: 'Test Game',
        sdl: sdl,
      );
      final level1 = Level(game: game);
      game.pushLevel(level1);
      expect(game.currentLevel, equals(level1));
      final level2 = Level(game: game);
      game.pushLevel(level2);
      expect(game.currentLevel, equals(level2));
    });
    test('One-off Task Test', () async {
      final game = Game(
        title: 'Test Game',
        sdl: sdl,
      );
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
        await game.tick(1);
        expect(i, isZero);
        expect(runner.numberOfRuns, isZero);
        expect(runner.runAfter, j);
      }
      await game.tick(1);
      expect(i, equals(1));
      expect(game.tasks, isEmpty);
    });
    test('Repeating Task Test', () async {
      final game = Game(
        title: 'Test Game',
        sdl: sdl,
      );
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
        await game.tick(1);
        expect(i, equals(0));
        expect(runner.runAfter, j);
      }
      await game.tick(1);
      expect(i, equals(1));
      expect(game.tasks, isNotEmpty);
      expect(game.tasks.first, runner);
      await game.tick(1);
      expect(i, equals(1));
      await game.tick(1);
      expect(i, equals(2));
      expect(game.tasks.length, equals(1));
      expect(game.tasks.first, runner);
    });
    test('Tasks with levels', () async {
      final game = Game(
        title: 'Tasks With Levels',
        sdl: sdl,
      );
      final level1 = Level(game: game);
      final level2 = Level(game: game);
      var x = 0;
      var y = 0;
      var z = 0;
      final taskWithoutLevel = Task(func: () => x++, runAfter: 5);
      final level1Task = Task(func: () => y++, runAfter: 5, level: level1);
      final level2Task = Task(func: () => z++, runAfter: 5, level: level2);
      [taskWithoutLevel, level1Task, level2Task].forEach(game.registerTask);
      final runnerWithoutLevel = game.tasks.first;
      expect(runnerWithoutLevel.value, taskWithoutLevel);
      final level1Runner = game.tasks[1];
      expect(level1Runner.value, level1Task);
      final level2Runner = game.tasks.last;
      expect(level2Runner.value, level2Task);
      expect(runnerWithoutLevel.runAfter, isZero);
      expect(level1Runner.runAfter, isZero);
      expect(level2Runner.runAfter, isZero);
      await game.tick(1);
      expect(x, isZero);
      expect(y, isZero);
      expect(z, isZero);
      expect(runnerWithoutLevel.runAfter, 1);
      expect(level1Runner.runAfter, isZero);
      expect(level2Runner.runAfter, isZero);
      game.pushLevel(level1);
      await game.tick(1);
      expect(x, isZero);
      expect(y, isZero);
      expect(z, isZero);
      expect(runnerWithoutLevel.runAfter, 2);
      expect(level1Runner.runAfter, 1);
      expect(level2Runner.runAfter, isZero);
      game.pushLevel(level2);
      await game.tick(1);
      expect(x, isZero);
      expect(y, isZero);
      expect(z, isZero);
      expect(runnerWithoutLevel.runAfter, 3);
      expect(level1Runner.runAfter, 1);
      expect(level2Runner.runAfter, 1);
      await game.tick(5);
      expect(x, 1);
      expect(y, isZero);
      expect(z, 1);
      expect(game.tasks.length, 1);
      expect(game.tasks, isNot(contains(level2Runner)));
      expect(game.tasks, isNot(contains(runnerWithoutLevel)));
      expect(game.tasks, contains(level1Runner));
      game.popLevel();
      await game.tick(5);
      expect(x, 1);
      expect(y, 1);
      expect(z, 1);
      expect(game.tasks, isEmpty);
    });
    test('.registerTask', () {
      final game = Game(
        title: 'Tasks that add tasks',
        sdl: sdl,
      );
      expect(game.tasks, isEmpty);
      game.registerTask(
        Task(
          runAfter: 0,
          func: () => game.callAfter(runAfter: 0, func: game.stop),
        ),
      );
      expect(game.tasks.length, equals(1));
      game.tick(0);
      expect(game.tasks.length, equals(1));
      expect(game.tasks.first.value.func, equals(game.stop));
    });
    test(
      '.callAfter',
      () {
        final game = Game(
          title: 'Test callAfter',
          sdl: sdl,
        );
        var i = 0;
        final task = game.callAfter(func: () => i++, runAfter: 15);
        expect(task, isA<Task>());
        expect(task.interval, isNull);
        expect(task.runAfter, 15);
        expect(game.tasks.length, 1);
        var runner = game.tasks.first;
        expect(runner.value, task);
        game.tick(14);
        expect(game.tasks.length, 1);
        runner = game.tasks.first;
        expect(runner.numberOfRuns, isZero);
        expect(runner.value, task);
        expect(runner.runAfter, 14);
        game.tick(1);
        expect(game.tasks, isEmpty);
        expect(runner.numberOfRuns, 1);
        expect(runner.value, task);
        expect(runner.runAfter, isZero);
      },
    );
    test('.unregisterTask', () {
      final game = Game(
        title: 'unregisterTask',
        sdl: sdl,
      );
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
      final game = Game(
        title: 'Replace Level',
        sdl: sdl,
      );
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
      final game = Game(
        title: 'Game.tick',
        sdl: sdl,
      );
      final level = TestLevel(game);
      game.tick(1);
      expect(level.lastTicked, isZero);
      game
        ..pushLevel(level)
        ..tick(1234);
      expect(level.lastTicked, equals(1234));
      game
        ..popLevel()
        ..tick(9876);
      expect(level.lastTicked, equals(1234));
    });
    test('.pushLevel', () async {
      final game = Game(
        title: 'Game.pushLevel',
        sdl: sdl,
      );
      final level1 = Level(game: game);
      final level2 = Level(game: game);
      game.pushLevel(level1);
      expect(game.currentLevel, equals(level1));
      expect(game.tasks, isEmpty);
      await game.tick(1);
      expect(game.currentLevel, equals(level1));
      expect(game.tasks, isEmpty);
      game.pushLevel(level2, after: 400);
      expect(game.currentLevel, equals(level1));
      expect(game.tasks.length, equals(1));
      await game.tick(399);
      expect(game.currentLevel, equals(level1));
      expect(game.tasks.length, equals(1));
      await game.tick(1);
      expect(game.currentLevel, equals(level2));
      expect(game.tasks, isEmpty);
    });
    test('.pushLevel with `after`', () async {
      final game = Game(
        title: 'Game.pushLevel',
        sdl: sdl,
      );
      final level = Level(game: game);
      game.pushLevel(level, after: 200);
      expect(game.currentLevel, isNull);
      expect(game.tasks.length, equals(1));
      var runner = game.tasks.first;
      expect(runner.numberOfRuns, isZero);
      expect(runner.runAfter, isZero);
      await game.tick(200);
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
      await game.tick(0);
      expect(game.currentLevel, isNull);
      expect(game.tasks.length, equals(1));
      expect(game.tasks, contains(runner));
      expect(runner.numberOfRuns, isZero);
      expect(runner.runAfter, isZero);
      await game.tick(399);
      expect(game.currentLevel, isNull);
      expect(game.tasks.length, equals(1));
      expect(game.tasks, contains(runner));
      expect(runner.numberOfRuns, isZero);
      expect(runner.runAfter, 399);
      await game.tick(1);
      expect(game.currentLevel, equals(level));
      expect(game.tasks, isEmpty);
      expect(runner.numberOfRuns, 1);
      expect(runner.runAfter, isZero);
    });
    test('Random sounds', () async {
      final game = Game(
        title: 'Play Random Sounds',
        sdl: sdl,
      );
      const randomSound1 = RandomSound(
        sound: AssetReference.file('sound1.wav'),
        minCoordinates: Point(1.0, 2.0),
        maxCoordinates: Point(5.0, 6.0),
        minInterval: 1000,
        maxInterval: 1000,
      );
      const randomSound2 = RandomSound(
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
      expect(
        l.getRandomSoundNextPlay(randomSound1).runAfter,
        randomSound1.minInterval,
      );
      expect(
        l.getRandomSoundNextPlay(randomSound2).runAfter,
        inOpenClosedRange(randomSound2.minInterval, randomSound2.maxInterval),
      );
      await game.tick(0);
      final randomSound1NextPlay = l.getRandomSoundNextPlay(randomSound1);
      expect(randomSound1NextPlay.runAfter, randomSound1.minInterval);
      final randomSound2NextPlay = l.getRandomSoundNextPlay(randomSound2);
      expect(
        randomSound2NextPlay.runAfter,
        inOpenClosedRange(randomSound2.minInterval, randomSound2.maxInterval),
      );
      await game.tick(randomSound1NextPlay.runAfter);
      expect(randomSound1NextPlay.runAfter, isZero);
      expect(randomSound2NextPlay.runAfter, greaterThan(0));
      await game.tick(1);
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
      await game.tick(randomSound2NextPlay.runAfter);
      expect(randomSound2NextPlay.runAfter, isZero);
      await game.tick(1);
      expect(
        randomSound2NextPlay.runAfter,
        inOpenClosedRange(randomSound2.minInterval, randomSound2.maxInterval),
      );
      expect(l.randomSoundPlaybacks[randomSound2], isNotNull);
      playback = l.randomSoundPlaybacks[randomSound2]!;
      expect(
        playback.sound.gain,
        inOpenClosedRange(randomSound2.minGain, randomSound2.maxGain),
      );
      expect(playback.channel.position, isA<SoundPosition3d>());
      position = playback.channel.position as SoundPosition3d;
      expect(
        position.x,
        inOpenClosedRange(
          randomSound2.minCoordinates.x,
          randomSound2.maxCoordinates.x,
        ),
      );
      expect(
        position.y,
        inOpenClosedRange(
          randomSound2.minCoordinates.y,
          randomSound2.maxCoordinates.y,
        ),
      );
      expect(position.z, isZero);
      expect(
        l.getRandomSoundNextPlay(randomSound2).runAfter,
        inOpenClosedRange(randomSound2.minInterval, randomSound2.maxInterval),
      );
    });
    test('Commands returning', () {
      const trigger1 = CommandTrigger(
        name: 'command1',
        description: 'First command',
      );
      const trigger2 = CommandTrigger(
        name: 'command2',
        description: 'Second command',
      );
      final game = Game(
        title: 'Commands',
        sdl: sdl,
        triggerMap: const TriggerMap(
          [trigger1, trigger2],
        ),
      );
      final level = Level(
        game: game,
        commands: {
          trigger1.name: const Command(),
          trigger2.name: const Command()
        },
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
        const trigger1 = CommandTrigger(
          name: 'command1',
          description: 'First command',
          keyboardKey: CommandKeyboardKey(ScanCode.right, altKey: true),
        );
        final trigger2 = CommandTrigger(
          name: 'command2',
          description: 'Second command',
          keyboardKey: CommandKeyboardKey(trigger1.keyboardKey!.scanCode),
        );
        final game = Game(
          title: 'Testing',
          sdl: sdl,
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
        game.handleSdlEvent(
          makeKeyboardEvent(
            sdl,
            trigger1.keyboardKey!.scanCode,
            KeyCode.digit0,
            modifiers: {KeyMod.alt},
            state: PressedState.pressed,
          ),
        );
        expect(list.length, 1);
        expect(list.first, 1);
        game.handleSdlEvent(
          makeKeyboardEvent(
            sdl,
            trigger1.keyboardKey!.scanCode,
            KeyCode.digit0,
            state: PressedState.pressed,
          ),
        );
        expect(list.length, 2);
        expect(list, [1, 2]);
      },
    );
  });

  group('Game.preferences', () {
    final game = Game(
      title: 'Preferences Tests',
      sdl: sdl,
      appName: 'preferences_tests_game',
      orgName: 'com.test',
    );
    test('.preferencesDirectory', () {
      const orgName = 'com.website';
      const appName = 'test_game';
      final game = Game(
        title: 'Preferences Directory',
        sdl: sdl,
        orgName: orgName,
        appName: appName,
      );
      expect(game.orgName, orgName);
      expect(game.appName, appName);
      final directory = game.preferencesDirectory;
      expect(
        directory.path,
        sdl.getPrefPath(
          game.orgName,
          game.appName,
        ),
      );
      expect(directory.existsSync(), isTrue);
      directory.deleteSync(recursive: true);
      expect(directory.existsSync(), isFalse);
      final directory2 = game.preferencesDirectory;
      expect(directory2.path, directory.path);
      expect(directory.existsSync(), isTrue);
      directory.deleteSync(recursive: true);
    });
    test('.preferencesFile', () {
      expect(
        game.preferencesFile.path,
        path.join(
          game.preferencesDirectory.path,
          game.preferencesFileName,
        ),
      );
    });
    test('.preferences', () {
      final preferences = game.preferences;
      expect(preferences.cache, isEmpty);
    });
  });
}
