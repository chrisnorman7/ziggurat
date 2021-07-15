/// Provides the [Wall] class.

import 'base.dart';

/// A wall on a map.
class Wall extends TileType {
  /// Create a wall.
  Wall({this.surmountable = false});

  /// Whether or not this wall can be fired / jumped over.
  ///
  /// This value could be used for basically anything.
  final bool surmountable;
}
