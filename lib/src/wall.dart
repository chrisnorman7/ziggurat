/// Provides the [Wall] class.
import 'dart:math';

import 'surface.dart';

/// A wall on a map.
class Wall with Surface {
  /// Create a wall.
  Wall(Point<int> start, Point<int> end,
      {String? sound, this.surmountable = false}) {
    this.start = start;
    this.end = end;
    this.sound = sound;
  }

  /// Whether or not this wall can be fired / jumped over.
  ///
  /// This value could be used for basically anything.
  final bool surmountable;
}
