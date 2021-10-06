/// Provides the [Ambiance] class.
import 'dart:math';

import '../game.dart';
import '../json/asset_reference.dart';
import '../sound/events/playback.dart';
import 'events/sound_channel.dart';

/// This class represents a playing ambiance.
class AmbiancePlayback {
  /// Create an instance.
  AmbiancePlayback(this.channel, this.sound);

  /// The channel that [sound] is playing through.
  final SoundChannel channel;

  /// The sound that is playing through [channel].
  final PlaySound sound;
}

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
  AmbiancePlayback? playback;
}
