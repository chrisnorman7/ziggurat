/// Provides the [SoundChannel] class.
import '../../error.dart';
import '../../game.dart';
import '../../json/sound_reference.dart';
import 'events_base.dart';
import 'sound_channel_filter.dart';

/// A channel for playing sounds through.
class SoundChannel extends SoundEvent {
  /// Create a channel.
  SoundChannel(
      {required this.game,
      required int id,
      SoundPosition? position,
      this.reverb,
      double gain = 0.7})
      : _gain = gain,
        _position = position ?? unpanned,
        super(id);

  /// The game object to use for this channel.
  final Game game;

  SoundPosition _position;

  /// The position of this channel.
  SoundPosition get position => _position;

  /// Set the position of this channel.
  set position(SoundPosition value) {
    if (value.runtimeType != _position.runtimeType) {
      throw PositionMismatchError(this, value);
    }
    _position = value;
    game.queueSoundEvent(SetSoundChannelPosition(id, value));
  }

  /// The ID of a reverb that was previously created.
  final int? reverb;

  double _gain;

  /// The gain of this channel.
  double get gain => _gain;

  /// Set the gain of this channel.
  set gain(double value) {
    _gain = value;
    game.queueSoundEvent(SetSoundChannelGain(id: id, gain: value));
  }

  /// Play a sound through this channel.
  PlaySound playSound(SoundReference sound,
      {double gain = 0.7, bool looping = false, bool keepAlive = false}) {
    final event = PlaySound(
        game: game,
        sound: sound,
        keepAlive: keepAlive,
        gain: gain,
        looping: looping,
        channel: id);
    game.queueSoundEvent(event);
    return event;
  }

  /// Remove any filtering applied to this channel.
  void clearFilter() => game.queueSoundEvent(SoundChannelFilter(id));

  /// Apply a lowpass to this channel.
  void filterLowpass(double frequency, {double q = 0.7071135624381276}) =>
      game.queueSoundEvent(SoundChannelLowpass(id, frequency, q));

  /// Apply a highpass to this channel.
  void filterHighpass(double frequency, {double q = 0.7071135624381276}) =>
      game.queueSoundEvent(SoundChannelHighpass(id, frequency, q));

  /// Add a bandpass to this channel.
  void filterBandpass(double frequency, double bandwidth) =>
      game.queueSoundEvent(SoundChannelBandpass(
          id: id, frequency: frequency, bandwidth: bandwidth));

  /// Destroy this channel.
  void destroy() => game.queueSoundEvent(DestroySoundChannel(id));
}

/// Destroy a [SoundChannel] instance.
class DestroySoundChannel extends SoundEvent {
  /// Create an event.
  DestroySoundChannel(int id) : super(id);
}

/// Set the gain for a [SoundChannel].
class SetSoundChannelGain extends SetSoundGain {
  /// Create an event.
  const SetSoundChannelGain({required int id, required double gain})
      : super(id: id, gain: gain);
}

/// Set the position for a [SoundChannel].
class SetSoundChannelPosition extends SoundEvent {
  /// Create an instance.
  const SetSoundChannelPosition(int id, this.position) : super(id);

  /// The new position.
  final SoundPosition position;
}
