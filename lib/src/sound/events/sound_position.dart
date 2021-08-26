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
/// You can set the left right panning with the [scalar] property, and the
/// elevation with the [elevation] property.
class SoundPositionPanned extends SoundPosition {
  /// Create a panned position.
  const SoundPositionPanned({required this.scalar, required this.elevation});

  /// The left right balance of this sound.
  final double scalar;

  /// The elevation of this sound.
  final double elevation;
}

/// A sound which should be positioned in 3d space.
class SoundPosition3d extends SoundPosition {
  /// Create the position.
  const SoundPosition3d(this.x, this.y, this.z);

  /// The x coordinate.
  final double x;

  /// The y coordinate.
  final double y;

  /// The z coordinate.
  final double z;
}
