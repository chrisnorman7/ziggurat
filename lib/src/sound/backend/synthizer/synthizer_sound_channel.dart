/// Provides the [SynthizerSoundChannel] class.
import 'package:dart_synthizer/dart_synthizer.dart';

import '../../../../wave_types.dart';
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
class SynthizerSoundChannel<T extends SoundPosition> implements SoundChannel {
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
  T get position {
    final s = source;
    if (s is DirectSource) {
      return unpanned as T;
    } else if (s is Source3D) {
      final p = s.position.value;
      return SoundPosition3d(x: p.x, y: p.y, z: p.z) as T;
    } else if (s is AngularPannedSource) {
      return SoundPositionAngular(
        azimuth: s.azimuth.value,
        elevation: s.elevation.value,
      ) as T;
    } else if (s is ScalarPannedSource) {
      return SoundPositionScalar(scalar: s.panningScalar.value) as T;
    } else {
      throw UnimplementedError('Cannot handle source $s.');
    }
  }

  /// Set the [source] position.
  set position(final T value) {
    if (value == unpanned) {
      throw UnimplementedError(
        'You cannot set the `position` for an unpanned source.',
      );
    } else if (value is SoundPosition3d) {
      (source as Source3D).position.value = Double3(value.x, value.y, value.z);
    } else if (value is SoundPositionAngular) {
      (source as AngularPannedSource)
        ..azimuth.value = value.azimuth
        ..elevation.value = value.elevation;
    } else if (value is SoundPositionScalar) {
      (source as ScalarPannedSource).panningScalar.value = value.scalar;
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
  void addReverb(covariant final SynthizerBackendReverb reverb) {
    context.configRoute(source, reverb.reverb);
  }

  /// Remove reverb from this channel.
  @override
  void removeReverb(covariant final SynthizerBackendReverb reverb) {
    context.removeRoute(source, reverb.reverb);
  }

  /// Add an echo to this channel.

  @override
  void addEcho(covariant final SynthizerBackendEcho echo) {
    context.configRoute(source, echo.echo);
  }

  /// Remove an echo from this channel.
  @override
  void removeEcho(covariant final SynthizerBackendEcho echo) {
    context.removeRoute(source, echo.echo);
  }

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

  @override
  Wave playSine({required final double frequency, final double gain = 0.7}) =>
      playWave(
        waveType: WaveType.sine,
        frequency: frequency,
        gain: gain,
      );

  @override
  SynthizerSound playSound({
    required final AssetReference assetReference,
    final bool keepAlive = false,
  }) {
    final buffer = backend.bufferCache.getBuffer(assetReference);
    final generator = context.createBufferGenerator(buffer: buffer);
    return SynthizerSound(
      backend: backend,
      keepAlive: keepAlive,
      source: source,
      generator: generator,
    );
  }

  @override
  Wave playSquare({
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

  @override
  Wave playTriangle({
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
    if (partials < 1 && waveType != WaveType.sine) {
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
    return SynthizerWave(
      backend: backend,
      generator: generator,
    );
  }

  @override
  void removeAllEffects() {
    source.removeAllRoutes();
  }
}
