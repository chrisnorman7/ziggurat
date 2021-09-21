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
/// You can set the left right panning with the [scalar] property.
class SoundPositionScalar extends SoundPosition {
  /// Create a panned position.
  const SoundPositionScalar({this.scalar = 0.0});

  /// The left right balance of this sound.
  final double scalar;
}

/// A sound which should be panned.
///
/// You can set the left right panning with the [azimuth] and [elevation]
/// properties.
class SoundPositionAngular extends SoundPosition {
  /// Create a panned position.
  const SoundPositionAngular({this.azimuth = 0.0, this.elevation = 0.0});

  /// The azimuth of this sound.
  final double azimuth;

  /// The elevation of this sound.
  final double elevation;
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
