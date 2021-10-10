/// Provides the [BoxMap] class.
import 'dart:math';

import 'box.dart';

/// A map made up of boxes.
class BoxMap {
  /// Create an instance.
  BoxMap({
    required this.name,
    required this.boxes,
    this.initialCoordinates = const Point(0, 0),
    this.initialHeading = 0,
  });

  /// The name of this map.
  final String name;

  /// Initial coordinates.
  ///
  /// These are the coordinates that players should be placed on when first
  /// joining the map.
  Point<double> initialCoordinates;

  /// The initial direction the player will face when starting on this map.
  final double initialHeading;

  /// All the boxes on this map.
  final List<Box> boxes;
}
