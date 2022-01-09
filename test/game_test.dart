import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

class TestLevel extends Level {
  /// Create.
  TestLevel(Game game)
      : lastTicked = 0,
        super(game);

  /// The number of milliseconds since the [game] ticked.
  int lastTicked;
  @override
  void tick(Sdl sdl, int timeDelta) {
    lastTicked = timeDelta;
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
      final level1 = Level(game);
      game.pushLevel(level1);
      expect(game.currentLevel, equals(level1));
      final level2 = Level(game);
      game.pushLevel(level2);
      expect(game.currentLevel, equals(level2));
    });
    test('One-off Task Test', () {
      final sdl = Sdl();
      final game = Game('Test Game');
      var i = 0;
      var task = game.registerTask(runAfter: 3, func: () => i++);
      expect(game.tasks.contains(task), isTrue);
      expect(task.runWhen, equals(3));
      expect(i, isZero);
      while (game.time < task.runWhen) {
        game.tick(sdl, 1);
        expect(
            game.time, allOf(greaterThanOrEqualTo(0), lessThan(task.runWhen)));
        expect(i, equals(0));
        game.time++;
      }
      game.tick(sdl, 1);
      expect(i, equals(1));
      expect(game.tasks, isEmpty);
      final now = DateTime.now().millisecondsSinceEpoch;
      game.time = 0;
      task = game.registerTask(runAfter: 5, func: () => 0, timeOffset: now);
      expect(task.runWhen, equals(now + 5));
    });
    test('Repeating Task Test', () {
      final sdl = Sdl();
      final game = Game('Test Game');
      var i = 0;
      final task = game.registerTask(runAfter: 3, func: () => i++, interval: 2);
      expect(task.interval, equals(2));
      expect(game.tasks, contains(task));
      expect(task.runWhen, equals(3));
      expect(i, isZero);
      while (game.time < task.runWhen) {
        game.tick(sdl, 1);
        expect(
            game.time, allOf(greaterThanOrEqualTo(0), lessThan(task.runWhen)));
        expect(i, equals(0));
        game.time++;
      }
      game.tick(sdl, 1);
      expect(i, equals(1));
      expect(game.tasks, isNotEmpty);
      expect(game.tasks.first, equals(task));
      game
        ..time += 1
        ..tick(sdl, 1);
      expect(i, equals(1));
      game
        ..time += 1
        ..tick(sdl, 1);
      expect(i, equals(2));
      expect(game.tasks.length, equals(1));
    });
    test('Tasks adding tasks', () {
      final sdl = Sdl();
      final game = Game('Tasks that add tasks');
      expect(game.tasks, isEmpty);
      game.registerTask(
          runAfter: 0,
          func: () => game.registerTask(runAfter: 0, func: game.stop));
      expect(game.tasks.length, equals(1));
      game.tick(sdl, 0);
      expect(game.tasks.length, equals(1));
      expect(game.tasks.first.func, equals(game.stop));
    });
    test('.unregisterTask', () {
      final game = Game('unregisterTask');
      game.registerTask(runAfter: 1234, func: game.stop);
      expect(game.tasks.length, equals(1));
      game.unregisterTask(
          () => game.registerTask(runAfter: 200, func: game.stop));
      expect(game.tasks.length, equals(1));
      game.unregisterTask(game.stop);
      expect(game.tasks, isEmpty);
    });
    test('replaceLevel', () {
      final game = Game('Replace Level');
      final level1 = Level(game);
      final level2 = Level(game);
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
      final task = game.tasks.first;
      expect(task.runWhen, equals(2000));
    });
    test('.started', () async {
      final sdl = Sdl()..init();
      var i = 0;
      final game = Game('Game.started');
      expect(game.started, isZero);
      final now = DateTime.now().millisecondsSinceEpoch;
      game.run(sdl, onStart: () => i++);
      await Future<void>.delayed(Duration(milliseconds: 100));
      expect(
          game.started,
          allOf(greaterThanOrEqualTo(now),
              lessThan(DateTime.now().millisecondsSinceEpoch)));
      expect(i, equals(1));
      sdl.quit();
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
      final level1 = Level(game);
      final level2 = Level(game);
      game.pushLevel(level1);
      expect(game.currentLevel, equals(level1));
      expect(game.tasks, isEmpty);
      await game.tick(sdl, 0);
      expect(game.currentLevel, equals(level1));
      expect(game.tasks, isEmpty);
      game.pushLevel(level2, after: 400);
      expect(game.currentLevel, equals(level1));
      expect(game.tasks.length, equals(1));
      game.time = 399;
      await game.tick(sdl, 0);
      expect(game.currentLevel, equals(level1));
      expect(game.tasks.length, equals(1));
      game.time = 400;
      await game.tick(sdl, 0);
      expect(game.currentLevel, equals(level2));
      expect(game.tasks, isEmpty);
    });
    test('.pushLevel (instantly)', () async {
      final sdl = Sdl();
      var game = Game('Game.pushLevel');
      final level = Level(game);
      game.pushLevel(level, after: 200);
      expect(game.currentLevel, isNull);
      expect(game.tasks.length, equals(1));
      final now = DateTime.now().millisecondsSinceEpoch;
      game
        ..time = now
        ..tick(sdl, 0);
      expect(game.currentLevel, equals(level));
      expect(game.tasks, isEmpty);
      game = Game('Game.pushLevel', time: now);
      expect(game.time, equals(now));
      expect(game.currentLevel, isNull);
      expect(game.tasks, isEmpty);
      game.pushLevel(level, after: 400);
      expect(game.currentLevel, isNull);
      expect(game.tasks.length, equals(1));
      await game.tick(sdl, 0);
      expect(game.currentLevel, isNull);
      expect(game.tasks.length, equals(1));
      game.time = now + 399;
      await game.tick(sdl, 0);
      expect(game.currentLevel, isNull);
      expect(game.tasks.length, equals(1));
      game.time = now + 400;
      await game.tick(sdl, 0);
      expect(game.currentLevel, equals(level));
      expect(game.tasks, isEmpty);
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
      final l = Level(game, randomSounds: [randomSound1, randomSound2]);
      game.pushLevel(l);
      expect(l.randomSoundPlaybacks[randomSound1], isNull);
      expect(l.randomSoundPlaybacks[randomSound2], isNull);
      game.time = DateTime.now().millisecondsSinceEpoch;
      await game.tick(sdl, 0);
      expect(l.randomSoundPlaybacks[randomSound1], isNull);
      expect(l.randomSoundNextPlays[randomSound1],
          equals(game.time + randomSound1.minInterval));
      expect(l.randomSoundPlaybacks[randomSound2], isNull);
      expect(
          l.randomSoundNextPlays[randomSound2],
          inOpenClosedRange(game.time + randomSound2.minInterval,
              game.time + randomSound2.maxInterval));
      game.time = l.randomSoundNextPlays[randomSound1]!;
      await game.tick(sdl, 0);
      expect(l.randomSoundPlaybacks[randomSound1], isNotNull);
      expect(l.randomSoundPlaybacks[randomSound2], isNull);
      var playback = l.randomSoundPlaybacks[randomSound1]!;
      expect(playback.sound.gain, equals(randomSound1.minGain));
      expect(playback.channel.position, isA<SoundPosition3d>());
      var position = playback.channel.position as SoundPosition3d;
      expect(
          position.x,
          inOpenClosedRange(
              randomSound1.minCoordinates.x, randomSound1.maxCoordinates.x));
      expect(
          position.y,
          inOpenClosedRange(
              randomSound1.minCoordinates.y, randomSound1.maxCoordinates.y));
      expect(position.z, isZero);
      game.time = l.randomSoundNextPlays[randomSound2]!;
      await game.tick(sdl, 0);
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
          l.randomSoundNextPlays[randomSound2],
          inOpenClosedRange(game.time + randomSound2.minInterval,
              game.time + randomSound2.maxInterval));
    });
  });
}
