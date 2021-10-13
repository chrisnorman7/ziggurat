/// Provides global sound events.
import 'dart:math';

import 'events_base.dart';

/// Set the position of the listener.
class ListenerPositionEvent extends SoundEvent {
  /// Create an instance.
  const ListenerPositionEvent(this.x, this.y, this.z) : super();

  /// The x coordinate.
  final double x;

  /// The y coordinate.
  final double y;

  /// The z coordinate.
  final double z;
}

/// Change the orientation of the listener.
class ListenerOrientationEvent extends SoundEvent {
  /// Create an instance.
  const ListenerOrientationEvent(
      this.x1, this.y1, this.z1, this.x2, this.y2, this.z2)
      : super();

  /// Create an instance from [angle].
  factory ListenerOrientationEvent.fromAngle(double angle) =>
      ListenerOrientationEvent(
          sin(angle * pi / 180), cos(angle * pi / 180), 0, 0, 0, 1);

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
}

/// Possible default panner strategies.
enum DefaultPannerStrategy {
  /// Stereo sound.
  stereo,

  /// HRTF.
  hrtf,
}

/// Set default panner strategy.
class SetDefaultPannerStrategy extends SoundEvent {
  /// Create an instance.
  const SetDefaultPannerStrategy(this.strategy) : super();

  /// The new strategy to use.
  final DefaultPannerStrategy strategy;
}
