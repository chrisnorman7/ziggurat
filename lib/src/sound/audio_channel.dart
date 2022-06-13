/// Provides the [AudioChannel] class.
import 'package:dart_synthizer/dart_synthizer.dart';

import 'reverb.dart';

/// A channel to play sounds through.
class AudioChannel {
  /// Create the channel.
  AudioChannel(this.id, this.source, this.reverb)
      : sounds = {},
        waves = {};

  /// The id of this channel.
  final int id;

  /// The audio source to use.
  Source source;

  /// The reverb this channel is feeding.
  Reverb? reverb;

  /// The sounds that are playing through this channel.
  final Map<int, BufferGenerator> sounds;

  /// The waves that are playing through this channel.
  final Map<int, FastSineBankGenerator> waves;

  /// Destroy this channel.
  void destroy() => source.destroy();
}
