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
    test('Task Tests', () {
      final game = Game('Test Game');
      final sdl = Sdl();
      var i = 0;
      final task = game.registerTask(3, () {
        i++;
      });
      expect(game.tasks.contains(task), isTrue);
      expect(task.runWhen, equals(3));
      expect(i, equals(0));
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
    });
  });
}
