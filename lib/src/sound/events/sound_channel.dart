// ignore_for_file: prefer_final_parameters
/// Provides the [SoundChannel] class.
import '../../../wave_types.dart';
import '../../error.dart';
import '../../game.dart';
import '../../json/asset_reference.dart';
import 'events_base.dart';
import 'playback.dart';
import 'reverb.dart';
import 'sound_channel_filter.dart';
import 'sound_position.dart';

/// A channel for playing sounds through.
class SoundChannel extends SoundEvent {
  /// Create a channel.
  SoundChannel({
    required this.game,
    required final int id,
    final SoundPosition position = unpanned,
    final int? reverb,
    final double gain = 0.7,
  })  : _reverb = reverb,
        _gain = gain,
        _position = position,
        super(id: id);

  /// The game object to use for this channel.
  final Game game;

  SoundPosition _position;

  /// The position of this channel.
  SoundPosition get position => _position;

  /// Set the position of this channel.
  set position(final SoundPosition value) {
    if (value.runtimeType != _position.runtimeType) {
      throw PositionMismatchError(this, value);
    }
    _position = value;
    game.queueSoundEvent(SetSoundChannelPosition(id!, value));
  }

  /// The ID of a reverb that was previously created.
  int? _reverb;

  /// Get the ID of the current reverb.
  int? get reverb => _reverb;

  /// Set the reverb for this channel.
  ///
  /// The given [reverbId] must be the id of a [CreateReverb] instance created
  /// by [Game.createReverb].
  ///
  /// If [reverbId] is `null`, then the reverb will be cleared.
  set reverb(final int? reverbId) {
    _reverb = reverbId;
    game.queueSoundEvent(SetSoundChannelReverb(id!, reverbId));
  }

  double _gain;

  /// The gain of this channel.
  double get gain => _gain;

  /// Set the gain of this channel.
  set gain(final double value) {
    _gain = value;
    game.queueSoundEvent(SetSoundChannelGain(id: id!, gain: value));
  }

  /// Play a sound through this channel.
  PlaySound playSound(
    final AssetReference sound, {
    final double gain = 0.7,
    final bool looping = false,
    final bool keepAlive = false,
  }) {
    final event = PlaySound(
      game: game,
      sound: sound,
      keepAlive: keepAlive,
      gain: gain,
      looping: looping,
      channel: id!,
    );
    game.queueSoundEvent(event);
    return event;
  }

  /// Play a wave of the given [waveType] at the given [frequency] through this
  /// channel.
  ///
  /// If [waveType] is [WaveType.sine], then [partials] are ignored.
  ///
  /// If [partials] is `< 1`, then [StateError] is thrown.
  PlayWave playWave({
    required final WaveType waveType,
    required final double frequency,
    final int partials = 1,
    final double gain = 0.7,
  }) {
    if (partials < 1 && waveType != WaveType.sine) {
      throw StateError('Synthizer does not like `partials` being less than 1.');
    }
    final wave = PlayWave(
      game: game,
      channel: id!,
      waveType: waveType,
      frequency: frequency,
      partials: partials,
      gain: gain,
    );
    game.queueSoundEvent(wave);
    return wave;
  }

  /// Play a sine wave.
  PlayWave playSine(
    final double frequency, {
    final double gain = 0.7,
  }) =>
      playWave(
        waveType: WaveType.sine,
        frequency: frequency,
        gain: gain,
      );

  /// Play a triangle wave.
  PlayWave playTriangle(
    final double frequency, {
    final int partials = 1,
    final double gain = 0.7,
  }) =>
      playWave(
        waveType: WaveType.triangle,
        frequency: frequency,
        partials: partials,
        gain: gain,
      );

  /// Play a square wave.
  PlayWave playSquare(
    final double frequency, {
    final int partials = 1,
    final double gain = 0.7,
  }) =>
      playWave(
        waveType: WaveType.square,
        frequency: frequency,
        partials: partials,
        gain: gain,
      );

  /// Play a saw wave.
  PlayWave playSaw(
    final double frequency, {
    final int partials = 1,
    final double gain = 0.7,
  }) =>
      playWave(
        waveType: WaveType.saw,
        frequency: frequency,
        partials: partials,
        gain: gain,
      );

  /// Remove any filtering applied to this channel.
  void clearFilter() => game.queueSoundEvent(SoundChannelFilter(id!));

  /// Apply a lowpass to this channel.
  void filterLowpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  }) =>
      game.queueSoundEvent(SoundChannelLowpass(id!, frequency, q));

  /// Apply a highpass to this channel.
  void filterHighpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  }) =>
      game.queueSoundEvent(SoundChannelHighpass(id!, frequency, q));

  /// Add a bandpass to this channel.
  void filterBandpass(final double frequency, final double bandwidth) =>
      game.queueSoundEvent(
        SoundChannelBandpass(
          id: id!,
          frequency: frequency,
          bandwidth: bandwidth,
        ),
      );

  /// Destroy this channel.
  void destroy() => game.queueSoundEvent(DestroySoundChannel(id!));

  /// Describe this object.
  @override
  String toString() =>
      '<$runtimeType id: $id, position: $_position, reverb: $reverb, '
      'gain: $_gain>';
}

/// Destroy a [SoundChannel] instance.
class DestroySoundChannel extends DestroySound {
  /// Create an event.
  const DestroySoundChannel(super.id);
}

/// Set the gain for a [SoundChannel].
class SetSoundChannelGain extends SetSoundGain {
  /// Create an event.
  const SetSoundChannelGain({required super.id, required super.gain});
}

/// Set the position for a [SoundChannel].
class SetSoundChannelPosition extends SoundEvent {
  /// Create an instance.
  const SetSoundChannelPosition(final int id, this.position) : super(id: id);

  /// The new position.
  final SoundPosition position;

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id, position: $position>';
}

/// Set the reverb for the channel with the given [id].
class SetSoundChannelReverb extends SoundEvent {
  /// Create an instance.
  ///
  /// The given [id] should be the ID of the [SoundChannel] to set the reverb
  /// for.
  const SetSoundChannelReverb(final int id, this.reverb) : super(id: id);

  /// The reverb preset to use.
  ///
  /// The preset must have been created with [Game.createReverb].
  final int? reverb;

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id, reverb: $reverb>';
}
