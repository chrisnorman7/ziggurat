import 'dart:math';

/// The position of the listener.
class ListenerPosition {
  /// Create an instance.
  const ListenerPosition(this.x, this.y, this.z);

  /// The x coordinate.
  final double x;

  /// The y coordinate.
  final double y;

  /// The z coordinate.
  final double z;

  /// Describe this object.
  @override
  String toString() => '<$runtimeType x: $x, y: $y, z: $z>';
}

/// The orientation of the listener.
class ListenerOrientation {
  /// Create an instance.
  const ListenerOrientation(
    this.x1,
    this.y1,
    this.z1,
    this.x2,
    this.y2,
    this.z2,
  );

  /// Create an instance from [angle].
  ListenerOrientation.fromAngle(final double angle)
      : x1 = sin(angle * pi / 180),
        y1 = cos(angle * pi / 180),
        z1 = 0.0,
        x2 = 0.0,
        y2 = 0.0,
        z2 = 1.0;

  /// X1.
  final double x1;

  /// Y1.
  final double y1;

  /// Z1.
  final double z1;

  /// X2.
  final double x2;

  /// Y2.
  final double y2;

  /// Z2.
  final double z2;

  /// Describe this object.
  @override
  String toString() =>
      '<$runtimeType x1: $x1, y1: $y1, z1: $z1, x2: $x2, y2: $y2, z2: $z2>';
}

/// Possible default panner strategies.
enum DefaultPannerStrategy {
  /// Stereo sound.
  stereo,

  /// HRTF.
  hrtf,
}
