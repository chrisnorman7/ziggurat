/// Provides the [Surface] class.
import 'base.dart';

/// A simple surface that can be walked on.
class Surface extends TileType {
  /// Create a surface.
  Surface({this.walkInterval = 0.5});

  /// How many seconds must elapse between player footsteps.
  final double walkInterval;
}
