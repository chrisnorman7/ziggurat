/// Provides the [RandomSoundContainer] class.
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';

/// A class for containing random sound data.
class RandomSoundContainer {
  /// Create the data.
  RandomSoundContainer(this.coordinates, this.source);

  /// The coordinates of the sound.
  final Point<double> coordinates;

  /// The source which is playing the sound.
  final Source3D source;
}
