/// Provides the [Ambiance] class.
import 'dart:math';

import '../json/sound_reference.dart';

/// A constantly playing sound on a map.
class Ambiance {
  /// Create an instance.
  Ambiance({required this.sound, this.position, this.gain = 0.75});

  /// The path where the sound file is stored.
  final SoundReference sound;

  /// The position of the sound.
  ///
  /// If this value is `null`, then the ambiance will not be positional.
  ///
  /// Changing this value at runtime does not yet change the position of the
  /// sound.
  final Point<double>? position;

  /// The gain of the sound.
  ///
  /// Changing this value at runtime does not yet change the volume of the
  /// sound.
  final double gain;
}
