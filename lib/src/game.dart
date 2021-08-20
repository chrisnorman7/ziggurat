/// Provides the [Game] class.
import 'levels/level.dart';

/// The main game object.
class Game {
  /// Create an instance.
  Game(this.title) : _levels = [];

  /// The title of this game.
  ///
  /// This value will be used to determine the title of the resulting window.
  final String title;

  /// The level stack of this game.
  final List<Level> _levels;

  /// Get the current level.
  ///
  /// This is the level which is last in the levels stack.
  Level? get currentLevel => _levels.isEmpty ? null : _levels.last;

  /// Push a level onto the stack.
  void pushLevel(Level level) {
    final cl = currentLevel;
    level.onPush();
    _levels.add(level);
    if (cl != null) {
      cl.onCover(level);
    }
  }

  /// Pop the most recent level.
  Level? popLevel() {
    if (_levels.isNotEmpty) {
      final oldLevel = _levels.removeLast()..onPop();
      final cl = currentLevel;
      if (cl != null) {
        cl.onReveal(oldLevel);
      }
      return oldLevel;
    }
  }
}
