/// Provides the [SoundChannelFilter] class and subclasses.
import 'events_base.dart';
import 'sound_channel.dart';

/// An event for filtering [SoundChannel] instances.
class SoundChannelFilter extends SoundEvent {
  /// Create an event.
  const SoundChannelFilter(int id) : super(id: id);
}

/// An event for applying a lowpass to a [SoundChannel] instance.
class SoundChannelLowpass extends SoundChannelFilter {
  /// Create an instance.
  const SoundChannelLowpass(int id, this.frequency, this.q) : super(id);

  /// The frequency of the low pass.
  final double frequency;

  /// The q value.
  final double q;
}

/// An event for applying a highpass to a [SoundChannel] instance.
class SoundChannelHighpass extends SoundChannelLowpass {
  /// Create an instance.
  const SoundChannelHighpass(int id, double frequency, double q)
      : super(id, frequency, q);
}

/// An event for applying a bandpass to a [SoundChannel] instance.
class SoundChannelBandpass extends SoundChannelFilter {
  /// Create an instance.
  const SoundChannelBandpass(
      {required int id, required this.frequency, required this.bandwidth})
      : super(id);

  /// The frequency to start at.
  final double frequency;

  /// The bandwidth of the filter.
  final double bandwidth;
}
