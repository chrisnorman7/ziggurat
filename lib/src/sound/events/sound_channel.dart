/// Provides the [SoundChannel] class.
import '../../error.dart';
import '../../game.dart';
import '../../json/asset_reference.dart';
import 'events_base.dart';
import 'sound_channel_filter.dart';

/// A channel for playing sounds through.
class SoundChannel extends SoundEvent {
  /// Create a channel.
  SoundChannel(
      {required this.game,
      required int id,
      SoundPosition position = unpanned,
      this.reverb,
      double gain = 0.7})
      : _gain = gain,
        _position = position,
        super(id: id);

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
    game.queueSoundEvent(SetSoundChannelPosition(id!, value));
  }

  /// The ID of a reverb that was previously created.
  int? reverb;

  /// Set the reverb for this channel.
  ///
  /// The given [createdReverb] must have been created by [Game.createReverb].
  ///
  /// If [createdReverb] is `null`, then the reverb will be cleared.
  ///
  /// This method does not set the current [reverb], as this value will be
  /// needed by the sound subsystem.
  ///
  /// The responsibility for setting this value therefore, falls to the sound
  /// subsystem.
  void setReverb(CreateReverb? createdReverb) {
    final reverbId = createdReverb?.id;
    reverb = reverbId;
    game.queueSoundEvent(SetSoundChannelReverb(id!, reverbId));
  }

  double _gain;

  /// The gain of this channel.
  double get gain => _gain;

  /// Set the gain of this channel.
  set gain(double value) {
    _gain = value;
    game.queueSoundEvent(SetSoundChannelGain(id: id!, gain: value));
  }

  /// Play a sound through this channel.
  PlaySound playSound(AssetReference sound,
      {double gain = 0.7, bool looping = false, bool keepAlive = false}) {
    final event = PlaySound(
        game: game,
        sound: sound,
        keepAlive: keepAlive,
        gain: gain,
        looping: looping,
        channel: id!);
    game.queueSoundEvent(event);
    return event;
  }

  /// Remove any filtering applied to this channel.
  void clearFilter() => game.queueSoundEvent(SoundChannelFilter(id!));

  /// Apply a lowpass to this channel.
  void filterLowpass(double frequency, {double q = 0.7071135624381276}) =>
      game.queueSoundEvent(SoundChannelLowpass(id!, frequency, q));

  /// Apply a highpass to this channel.
  void filterHighpass(double frequency, {double q = 0.7071135624381276}) =>
      game.queueSoundEvent(SoundChannelHighpass(id!, frequency, q));

  /// Add a bandpass to this channel.
  void filterBandpass(double frequency, double bandwidth) =>
      game.queueSoundEvent(SoundChannelBandpass(
          id: id!, frequency: frequency, bandwidth: bandwidth));

  /// Destroy this channel.
  void destroy() => game.queueSoundEvent(DestroySoundChannel(id!));
}

/// Destroy a [SoundChannel] instance.
class DestroySoundChannel extends SoundEvent {
  /// Create an event.
  const DestroySoundChannel(int id) : super(id: id);
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
  const SetSoundChannelPosition(int id, this.position) : super(id: id);

  /// The new position.
  final SoundPosition position;
}

/// Set the reverb for the channel with the given [id].
class SetSoundChannelReverb extends SoundEvent {
  /// Create an instance.
  ///
  /// The given [id] should be the ID of the [SoundChannel] to set the reverb
  /// for.
  const SetSoundChannelReverb(int id, this.reverb) : super(id: id);

  /// The reverb preset to use.
  ///
  /// The preset must have been created with [Game.createReverb].
  final int? reverb;
}
