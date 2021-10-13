/// Provides the [SoundChannelGroup] class.
import 'events_base.dart';
import 'sound_channel.dart';

/// A class that allows you to group [SoundChannel] instances.
class SoundChannelGroup {
  /// Create a group.
  const SoundChannelGroup(this.channels);

  /// The sound channels that have been registered with this instance.
  final List<SoundChannel> channels;
}
