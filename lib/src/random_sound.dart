/// Provides the [RandomSound] class.
import 'dart:io';
import 'dart:math';

/// A random sound.
///
/// This sound will be played at a random point on a map, at a random interval.
class RandomSound {
  /// Create an instance.
  RandomSound(this.path, this.minCoordinates, this.maxCoordinates,
      this.minInterval, this.maxInterval,
      {this.minGain = 0.75, this.maxGain = 0.75});

  /// The sound to play.
  final FileSystemEntity path;

  /// The minimum coordinates.
  final Point<double> minCoordinates;

  /// The maximum coordinates.
  final Point<double> maxCoordinates;

  /// The minimum number of milliseconds between this sound playing.
  final int minInterval;

  /// The maximum number of milliseconds between this sound playing.
  final int maxInterval;

  /// The minimum gain.
  final double minGain;

  /// The maximum gain.
  final double maxGain;
}
