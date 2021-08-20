/// Provides the [WallLocation] class.
import 'dart:math';

import 'box.dart';
import 'box_types/wall.dart';

/// The location of a wall.
class WallLocation {
  /// Create an instance.
  WallLocation(this.wall, this.coordinates);

  /// The wall which has been found.
  final Box<Wall> wall;

  /// The coordinates where the wall was found.
  ///
  /// This position will be in a straight line from the player, so may not be
  /// located at a corner of the box.
  final Point<double> coordinates;
}
