/// Provides classes for use with the left/right radar.
import 'box.dart';
import 'box_types/wall.dart';

/// The state of the left/right radar.
class LeftRightRadarState {
  /// The current object to the west.
  Box<Wall>? westBox;

  /// The current object to the east.
  Box<Wall>? eastBox;
}
