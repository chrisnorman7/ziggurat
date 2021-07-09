/// Provides the [Tile] class.
import 'dart:math';

import 'surface.dart';

/// A tile on a map.
class Tile with Surface {
  /// Create a tile.
  Tile(this.name, Point<int> start, Point<int> end, {String? sound}) {
    this.start = start;
    this.end = end;
    this.sound = sound;
  }

  /// The name of this tile.
  final String name;

  /// What happens when this tile is "activated".
  ///
  /// Exactly when a tile is activated is left up to the programmer, but maybe
  /// when the enter key is pressed.
  void onActivate() {}
}
