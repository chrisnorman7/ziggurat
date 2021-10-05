import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('Game tests', () {
    test('Initialization', () {
      final game = Game('Test Game');
      expect(game.title, equals('Test Game'));
      expect(game.currentLevel, isNull);
      expect(game.triggerMap.triggers, equals(<String, CommandTrigger>{}));
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
      final game = Game('Test Game');
      final sdl = Sdl();
      var i = 0;
      var task = game.registerTask(3, () {
        i++;
      });
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
      task = game.registerTask(5, () => 0, timeOffset: now);
      expect(task.runWhen, equals(now + 5));
    });
    test('Repeating Task Test', () {
      final game = Game('Test Game');
      final sdl = Sdl();
      var i = 0;
      final task = game.registerTask(3, () {
        i++;
      }, interval: 2);
      expect(task.interval, equals(2));
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
      final game = Game('Game.started');
      expect(game.started, isZero);
      final now = DateTime.now().millisecondsSinceEpoch;
      game.run(sdl);
      await Future<void>.delayed(Duration(milliseconds: 100));
      expect(
          game.started,
          allOf(greaterThanOrEqualTo(now),
              lessThan(DateTime.now().millisecondsSinceEpoch)));
    });
  });
}
