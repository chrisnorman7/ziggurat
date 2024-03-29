/// Provides the [SynthizerSoundChannel] class.
import 'package:dart_synthizer/dart_synthizer.dart';

import '../../../../wave_types.dart';
import '../../../error.dart';
import '../../../json/asset_reference.dart';
import '../sound_channel.dart';
import '../sound_position.dart';
import '../wave.dart';
import 'effects/synthizer_backend_echo.dart';
import 'effects/synthizer_backend_reverb.dart';
import 'synthizer_sound.dart';
import 'synthizer_sound_backend.dart';
import 'synthizer_wave.dart';

/// A synthizer sound channel.
class SynthizerSoundChannel implements SoundChannel {
  /// Create an instance.
  const SynthizerSoundChannel({
    required this.backend,
    required this.source,
  });

  /// The backend this channel belongs to.
  final SynthizerSoundBackend backend;

  /// Get the synthizer instance to use.
  Synthizer get synthizer => backend.context.synthizer;

  /// Get the context to use.
  Context get context => backend.context;

  /// The synthizer source to use.
  final Source source;

  /// Destroy the [source].
  @override
  void destroy() {
    source.destroy();
  }

  /// Get the gain for [source].
  @override
  double get gain => source.gain.value;

  /// Set the gain for [source].
  set gain(final double value) => source.gain.value = value;

  /// Get the position of [source].
  @override
  SoundPosition get position {
    final s = source;
    if (s is DirectSource) {
      return unpanned;
    } else if (s is Source3D) {
      final p = s.position.value;
      return SoundPosition3d(x: p.x, y: p.y, z: p.z);
    } else if (s is AngularPannedSource) {
      return SoundPositionAngular(
        azimuth: s.azimuth.value,
        elevation: s.elevation.value,
      );
    } else if (s is ScalarPannedSource) {
      return SoundPositionScalar(scalar: s.panningScalar.value);
    } else {
      throw UnimplementedError('Cannot handle source $s.');
    }
  }

  /// Set the [source] position.
  @override
  set position(final SoundPosition value) {
    final s = source;
    if (s is DirectSource) {
      throw UnimplementedError(
        'You cannot set the `position` for an unpanned source.',
      );
    } else if (s is Source3D) {
      if (value is! SoundPosition3d) {
        throw PositionMismatchError(this, value);
      }
      s.position.value = Double3(value.x, value.y, value.z);
    } else if (s is AngularPannedSource) {
      if (value is! SoundPositionAngular) {
        throw PositionMismatchError(this, value);
      }
      s
        ..azimuth.value = value.azimuth
        ..elevation.value = value.elevation;
    } else if (value is SoundPositionScalar) {
      if (s is! ScalarPannedSource) {
        throw PositionMismatchError(this, value);
      }
      s.panningScalar.value = value.scalar;
    } else {
      throw UnimplementedError('Cannot handle sound position $value.');
    }
  }

  /// Clear filtering.
  @override
  void clearFilter() {
    source.filter.value = BiquadConfig.designIdentity(synthizer);
  }

  /// Add a bandpass.
  @override
  void filterBandpass(final double frequency, final double bandwidth) {
    source.filter.value = BiquadConfig.designBandpass(
      synthizer,
      frequency,
      bandwidth,
    );
  }

  /// Add a highpass.
  @override
  void filterHighpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  }) {
    source.filter.value = BiquadConfig.designHighpass(
      synthizer,
      frequency,
      q: q,
    );
  }

  /// Add a low pass.
  @override
  void filterLowpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  }) {
    source.filter.value = BiquadConfig.designLowpass(
      synthizer,
      frequency,
      q: q,
    );
  }

  /// Add reverb to this channel.
  @override
  void addReverb({
    required covariant final SynthizerBackendReverb reverb,
    final double gain = 1.0,
    final double fadeTime = 0.01,
  }) {
    context.configRoute(
      source,
      reverb.reverb,
      fadeTime: fadeTime,
      gain: gain,
    );
  }

  /// Remove reverb from this channel.
  @override
  void removeReverb({
    required covariant final SynthizerBackendReverb reverb,
    final double fadeTime = 0.01,
  }) {
    context.removeRoute(
      source,
      reverb.reverb,
      fadeTime: fadeTime,
    );
  }

  /// Add an echo to this channel.
  @override
  void addEcho({
    required covariant final SynthizerBackendEcho echo,
    final double gain = 1.0,
    final double fadeTime = 0.01,
  }) {
    context.configRoute(
      source,
      echo.echo,
      fadeTime: fadeTime,
      gain: gain,
    );
  }

  /// Remove an echo from this channel.
  @override
  void removeEcho({
    required covariant final SynthizerBackendEcho echo,
    final double fadeTime = 0.01,
  }) {
    context.removeRoute(
      source,
      echo.echo,
      fadeTime: fadeTime,
    );
  }

  /// Play a saw wave.
  @override
  Wave playSaw(
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

  /// Play a sine wave.
  @override
  SynthizerWave playSine({
    required final double frequency,
    final double gain = 0.7,
  }) =>
      playWave(
        waveType: WaveType.sine,
        frequency: frequency,
        gain: gain,
      );

  /// Play a square wave.
  @override
  SynthizerWave playSquare({
    required final double frequency,
    final int partials = 1,
    final double gain = 0.7,
  }) =>
      playWave(
        waveType: WaveType.square,
        frequency: frequency,
        partials: partials,
        gain: gain,
      );

  /// Play a triangle wave.
  @override
  SynthizerWave playTriangle({
    required final double frequency,
    final int partials = 1,
    final double gain = 0.7,
  }) =>
      playWave(
        waveType: WaveType.triangle,
        frequency: frequency,
        partials: partials,
        gain: gain,
      );

  /// Play a wave.
  @override
  SynthizerWave playWave({
    required final WaveType waveType,
    required final double frequency,
    final int partials = 1,
    final double gain = 0.7,
  }) {
    if (partials < 1) {
      throw StateError('Synthizer does not like `partials` being less than 1.');
    }
    final FastSineBankGenerator generator;
    switch (waveType) {
      case WaveType.sine:
        generator = context.createSine(
          frequency,
          partials,
        );
        break;
      case WaveType.triangle:
        generator = context.createTriangle(
          frequency,
          partials,
        );
        break;
      case WaveType.square:
        generator = context.createSquare(
          frequency,
          partials,
        );
        break;
      case WaveType.saw:
        generator = context.createSaw(
          frequency,
          partials,
        );
        break;
    }
    generator.gain.value = gain;
    source.addGenerator(generator);
    return SynthizerWave(
      backend: backend,
      generator: generator,
    );
  }

  /// Configure lingering for the given [generator], according to [keepAlive].
  void configureLinger({
    required final Generator generator,
    required final bool keepAlive,
  }) {
    if (!keepAlive) {
      generator
        ..configDeleteBehavior(linger: true)
        ..destroy();
    }
  }

  /// Play a sound with the given [assetReference].
  @override
  SynthizerSound playSound({
    required final AssetReference assetReference,
    final bool keepAlive = false,
    final double? gain,
    final bool looping = false,
    final double pitchBend = 1.0,
  }) {
    final buffer = backend.bufferCache.getBuffer(assetReference);
    final generator = context.createBufferGenerator()
      ..gain.value = gain ?? assetReference.gain
      ..looping.value = looping
      ..pitchBend.value = pitchBend
      ..buffer.value = buffer;
    source.addGenerator(generator);
    configureLinger(generator: generator, keepAlive: keepAlive);
    return SynthizerSound(
      backend: backend,
      channel: this,
      keepAlive: keepAlive,
      generator: generator,
    );
  }

  /// Play a sound from the given [string].
  @override
  SynthizerSound playString({
    required final String string,
    final bool keepAlive = false,
    final double gain = 0.7,
    final bool looping = false,
    final double pitchBend = 1.0,
  }) {
    final buffer = Buffer.fromString(synthizer, string);
    final generator = context.createBufferGenerator()
      ..gain.value = gain
      ..looping.value = looping
      ..pitchBend.value = pitchBend
      ..buffer.value = buffer;
    source.addGenerator(generator);
    configureLinger(generator: generator, keepAlive: keepAlive);
    return SynthizerSound(
      backend: backend,
      channel: this,
      keepAlive: keepAlive,
      generator: generator,
    );
  }

  /// Remove all effects.
  @override
  void removeAllEffects() {
    source.removeAllRoutes();
  }
}
