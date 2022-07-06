/// Provides the [SilentSoundChannel] class.
import '../../../../wave_types.dart';
import '../../../json/asset_reference.dart';
import '../effects/backend_echo.dart';
import '../effects/backend_reverb.dart';
import '../sound.dart';
import '../sound_channel.dart';
import '../sound_position.dart';
import 'silent_sound.dart';
import 'silent_wave.dart';

/// A silent sound channel.
///
/// This class does nothing.
class SilentSoundChannel implements SoundChannel {
  /// Create an instance.
  SilentSoundChannel({
    required this.gain,
    this.position = unpanned,
  });

  @override
  void addEcho(final BackendEcho echo) {}

  @override
  void addReverb(final BackendReverb reverb) {}

  @override
  void clearFilter() {}

  @override
  void destroy() {}

  @override
  void filterBandpass(final double frequency, final double bandwidth) {}

  @override
  void filterHighpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  }) {}

  @override
  void filterLowpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  }) {}

  @override
  double gain;

  @override
  SilentWave playSaw(
    final double frequency, {
    final int partials = 1,
    final double gain = 0.7,
  }) =>
      playWave(
        waveType: WaveType.saw,
        frequency: frequency,
        gain: gain,
        partials: partials,
      );

  @override
  SilentWave playSine({
    required final double frequency,
    final double gain = 0.7,
  }) =>
      playWave(
        waveType: WaveType.sine,
        frequency: frequency,
        gain: gain,
      );

  @override
  SilentSound playSound({
    required final AssetReference assetReference,
    final bool keepAlive = false,
    final double gain = 0.7,
    final bool looping = false,
    final double pitchBend = 1.0,
  }) =>
      SilentSound(
        channel: this,
        gain: gain,
        keepAlive: keepAlive,
        looping: looping,
        pitchBend: pitchBend,
      );

  @override
  SilentWave playSquare({
    required final double frequency,
    final int partials = 1,
    final double gain = 0.7,
  }) =>
      playWave(
        waveType: WaveType.square,
        frequency: frequency,
        gain: gain,
        partials: partials,
      );

  @override
  SilentWave playTriangle({
    required final double frequency,
    final int partials = 1,
    final double gain = 0.7,
  }) =>
      playWave(
        waveType: WaveType.triangle,
        frequency: frequency,
        gain: gain,
        partials: partials,
      );

  @override
  SilentWave playWave({
    required final WaveType waveType,
    required final double frequency,
    final int partials = 1,
    final double gain = 0.7,
  }) =>
      SilentWave(gain: gain);

  @override
  SoundPosition position;

  @override
  void removeAllEffects() {}

  @override
  void removeEcho(final BackendEcho echo) {}

  @override
  void removeReverb(final BackendReverb reverb) {}

  /// Play a sound from the given [string].
  @override
  Sound playString({
    required final String string,
    final bool keepAlive = false,
    final double gain = 0.7,
    final bool looping = false,
    final double pitchBend = 1.0,
  }) =>
      SilentSound(
        channel: this,
        gain: gain,
        keepAlive: keepAlive,
        looping: looping,
        pitchBend: pitchBend,
      );
}
