import 'backend/sound.dart';
import 'backend/sound_channel.dart';

/// This class represents a playing sound.
class SoundPlayback {
  /// Create an instance.
  const SoundPlayback(this.channel, this.sound);

  /// The channel that [sound] is playing through.
  final SoundChannel channel;

  /// The sound that is playing through [channel].
  final Sound sound;
}
