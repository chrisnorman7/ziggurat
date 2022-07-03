/// Provides the [SoundChannel] class.
import '../../../wave_types.dart';
import '../../json/asset_reference.dart';
import 'effects/backend_echo.dart';
import 'effects/backend_reverb.dart';
import 'sound.dart';
import 'sound_position.dart';
import 'wave.dart';

/// A channel for playing sounds through.
abstract class SoundChannel<T extends SoundPosition> {
  /// The position of this channel.
  T get position;

  /// The Gain of this channel.
  double get gain;

  /// Remove any filtering applied to this channel.
  void clearFilter();

  /// Apply a lowpass to this channel.
  void filterLowpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  });

  /// Apply a highpass to this channel.
  void filterHighpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  });

  /// Add a bandpass to this channel.
  void filterBandpass(final double frequency, final double bandwidth);

  /// Add reverb to this channel.
  void addReverb(final BackendReverb reverb);

  /// Remove reverb from this channel.
  void removeReverb(final BackendReverb reverb);

  /// Add an echo to this channel.
  void addEcho(final BackendEcho echo);

  /// Remove an echo from this channel.
  void removeEcho(final BackendEcho echo);

  /// Remove all effects.
  void removeAllEffects();

  /// Play a sound with the given [assetReference].
  Sound playSound({
    required final AssetReference assetReference,
    final bool keepAlive = false,
  });

  /// Play a wave of the given [waveType] at the given [frequency] through this
  /// channel.
  ///
  /// If [waveType] is [WaveType.sine], then [partials] are ignored.
  ///
  /// If [partials] is `< 1`, then [StateError] is thrown.
  Wave playWave({
    required final WaveType waveType,
    required final double frequency,
    final int partials = 1,
    final double gain = 0.7,
  });

  /// Play a sine wave.
  Wave playSine({
    required final double frequency,
    final double gain = 0.7,
  });

  /// Play a triangle wave.
  Wave playTriangle({
    required final double frequency,
    final int partials = 1,
    final double gain = 0.7,
  });

  /// Play a square wave.
  Wave playSquare({
    required final double frequency,
    final int partials = 1,
    final double gain = 0.7,
  });

  /// Play a saw wave.
  Wave playSaw(
    final double frequency, {
    final int partials = 1,
    final double gain = 0.7,
  });

  /// Destroy this channel.
  void destroy();
}
