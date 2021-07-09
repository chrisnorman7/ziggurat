/// Provides the [RandomSound] class.

/// A random sound.
///
/// This sound will be played at a random point on a map, at a random interval.
class RandomSound {
  /// Create an instance.
  RandomSound(this.path, this.minX, this.minY, this.maxX, this.maxY,
      this.minInterval, this.maxInterval,
      {this.minGain = 0.75, this.maxGain = 0.75});

  /// The sound to play.
  final String path;

  /// The minimum x coordinate.
  final double minX;

  /// The minimum y coordinate.
  final double minY;

  /// The maximum x coordinate.
  final double maxX;

  /// The maximum y coordinate.
  final double maxY;

  /// The minimum number of seconds between this sound playing.
  final double minInterval;

  /// The maximum time between this sound playing.
  final double maxInterval;

  /// The minimum gain.
  final double minGain;

  /// The maximum gain.
  final double maxGain;
}
