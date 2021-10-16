/// Provides various movement constants.

/// A class which contains direction constants.
abstract class CardinalDirections {
  /// North.
  static const north = 0.0;

  /// Northeast.
  static const northeast = 45.0;

  /// East.
  static const east = 90.0;

  /// Southeast.
  static const southeast = 135.0;

  /// South.
  static const south = 180.0;

  /// Southwest.
  static const southwest = 225.0;

  /// West.
  static const west = 270.0;

  /// Northwest.
  static const northwest = 315.0;
}

/// Walking directions.
enum MovementDirections {
  /// Forwards.
  forward,

  /// Backwards.
  backward,
}

/// Turning directions.
enum TurnDirections {
  /// Left.
  left,

  /// Right.
  right,
}
