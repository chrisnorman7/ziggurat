/// Provides the [SoundChannelGroup] class.
import 'reverb.dart';
import 'sound_channel.dart';

/// A class that allows you to group [SoundChannel] instances.
class SoundChannelGroup {
  /// Create a group.
  const SoundChannelGroup(this.channels);

  /// The sound channels that have been registered with this instance.
  final List<SoundChannel> channels;

  /// Set the reverb for this group.
  set reverb(CreateReverb? createdReverb) {
    for (final element in channels) {
      element.reverb = createdReverb?.id;
    }
  }

  /// Set the group gain.
  set gain(double value) {
    for (final channel in channels) {
      channel.gain = value;
    }
  }

  /// Clear filters for all channels.
  void clearFilters() {
    for (final channel in channels) {
      channel.clearFilter();
    }
  }

  /// Apply a low pass to this group.
  void filterLowpass(double frequency, {double q = 0.7071135624381276}) {
    for (final channel in channels) {
      channel.filterLowpass(frequency, q: q);
    }
  }

  /// Apply a highpass to this group.
  void filterHighpass(double frequency, {double q = 0.7071135624381276}) {
    for (final channel in channels) {
      channel.filterHighpass(frequency, q: q);
    }
  }

  /// Add a bandpass to this group.
  void filterBandpass(double frequency, double bandwidth) {
    for (final channel in channels) {
      channel.filterBandpass(frequency, bandwidth);
    }
  }

  /// Destroy and remove every channel in this group.
  ///
  /// After this method is used, you will need to re-add [SoundChannel]
  /// instances to the [channels] list.
  void destroy() {
    while (channels.isNotEmpty) {
      channels.removeLast().destroy();
    }
  }
}
