/// Provides the base [Level] class.
import '../game.dart';

/// A level in a [Game] instance.
class Level {
  /// What should happen when this game is pushed into a level stack.
  void onPush() {}

  /// What should happen when this level is popped from a level stack.
  void onPop() {}

  /// What should happen when this level is covered by another level.
  void onCover(Level other) {}

  /// What should happen when this level is revealed by another level being
  /// popped from on top of it.
  void onReveal(Level old) {}
}
