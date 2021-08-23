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
    wasPushed = true;
  }

  /// This level was popped.
  @override
  void onPop() {
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

void main() {
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
  });
}
