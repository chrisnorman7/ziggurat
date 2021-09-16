/// Provides the [SoundPosition] class subclasses.

/// The default sound position.
///
/// This class represents a sound which should not be panned.
class SoundPosition {
  /// Create a default position.
  const SoundPosition();
}

/// An unpanned sound.
const unpanned = SoundPosition();

/// A sound which should be panned.
///
/// You can set the left right panning with the [azimuthOrScalar] property.
class SoundPositionPanned extends SoundPosition {
  /// Create a panned position.
  const SoundPositionPanned({this.azimuthOrScalar = 0.0, this.elevation});

  /// The left right balance of this sound.
  ///
  /// If [elevation] is `null`, then this value is treated as a scalar.
  ///
  /// Otherwise, this value is treated as an azimuth value.
  final double azimuthOrScalar;

  /// The elevation to use.
  ///
  /// If this value is not `null`, then [azimuthOrScalar] is treated as an
  /// azimuth value.
  final double? elevation;
}

/// A sound which should be positioned in 3d space.
class SoundPosition3d extends SoundPosition {
  /// Create the position.
  const SoundPosition3d({this.x = 0.0, this.y = 0.0, this.z = 0.0});

  /// The x coordinate.
  final double x;

  /// The y coordinate.
  final double y;

  /// The z coordinate.
  final double z;
}
