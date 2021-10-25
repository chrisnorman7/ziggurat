/// Provides the [SoundPlayback] class.
import 'events/playback.dart';
import 'events/sound_channel.dart';

/// This class represents a playing sound.
class SoundPlayback {
  /// Create an instance.
  const SoundPlayback(this.channel, this.sound);

  /// The channel that [sound] is playing through.
  final SoundChannel channel;

  /// The sound that is playing through [channel].
  final PlaySound sound;
}
