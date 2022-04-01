/// Provides the [SoundChannelFilter] class and subclasses.
import 'events_base.dart';
import 'sound_channel.dart';

/// An event for filtering [SoundChannel] instances.
class SoundChannelFilter extends SoundEvent {
  /// Create an event.
  const SoundChannelFilter(final int id) : super(id: id);

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id>';
}

/// An event for applying a lowpass to a [SoundChannel] instance.
class SoundChannelLowpass extends SoundChannelFilter {
  /// Create an instance.
  const SoundChannelLowpass(final int id, this.frequency, this.q) : super(id);

  /// The frequency of the low pass.
  final double frequency;

  /// The q value.
  final double q;

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id, frequency: $frequency, q: $q>';
}

/// An event for applying a highpass to a [SoundChannel] instance.
class SoundChannelHighpass extends SoundChannelLowpass {
  /// Create an instance.
  const SoundChannelHighpass(
    final int id,
    final double frequency,
    final double q,
  ) : super(id, frequency, q);
}

/// An event for applying a bandpass to a [SoundChannel] instance.
class SoundChannelBandpass extends SoundChannelFilter {
  /// Create an instance.
  const SoundChannelBandpass({
    required final int id,
    required this.frequency,
    required this.bandwidth,
  }) : super(id);

  /// The frequency to start at.
  final double frequency;

  /// The bandwidth of the filter.
  final double bandwidth;

  /// Describe this object.
  @override
  String toString() =>
      '<$runtimeType id: $id, frequency: $frequency, bandwidth: $bandwidth>';
}
