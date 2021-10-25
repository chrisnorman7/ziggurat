/// Provides the [Ambiance] class.
import 'dart:math';

import '../game.dart';
import '../json/asset_reference.dart';
import 'sound_playback.dart';

/// A constantly playing sound on a map.
class Ambiance {
  /// Create an instance.
  Ambiance({required this.sound, this.position, this.gain = 0.75});

  /// The reference to the asset.
  final AssetReference sound;

  /// The position of the sound.
  ///
  /// If this value is `null`, then the ambiance will not be positional, and
  /// will play through [Game.ambianceSounds].
  ///
  /// Changing this value at runtime does not yet change the position of the
  /// sound.
  final Point<double>? position;

  /// The gain of the sound.
  ///
  /// Changing this value at runtime does not yet change the volume of the
  /// sound.
  final double gain;

  /// Holds information about how this ambiance is playing.
  ///
  /// If this value is `null`, then this ambiance is not playing.
  SoundPlayback? playback;
}
