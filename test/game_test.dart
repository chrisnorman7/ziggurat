import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('Game tests', () {
    test('Initialization', () {
      final game = Game('Test Game');
      expect(game.title, equals('Test Game'));
      expect(game.currentLevel, isNull);
    });
    test('Current Level', () {
      final game = Game('Test Game');
      final level1 = Level();
      game.pushLevel(level1);
      expect(game.currentLevel, equals(level1));
      final level2 = Level();
      game.pushLevel(level2);
      expect(game.currentLevel, equals(level2));
    });
  });
}
