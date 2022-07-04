import 'package:dart_synthizer/dart_synthizer.dart';

import '../../../json/reverb_preset.dart';
import '../effects/backend_echo.dart';
import '../listener.dart';
import '../sound_backend.dart';
import '../sound_channel.dart';
import '../sound_position.dart';
import 'buffer_cache.dart';
import 'effects/synthizer_backend_echo.dart';
import 'effects/synthizer_backend_reverb.dart';
import 'synthizer_sound_channel.dart';

/// A sound backend which uses Synthizer.
class SynthizerSoundBackend implements SoundBackend {
  /// Create an instance.
  const SynthizerSoundBackend({
    required this.context,
    required this.bufferCache,
  });

  /// The context to use.
  final Context context;

  /// The buffer cache to use.
  final BufferCache bufferCache;

  /// Get a sound channel.
  @override
  SoundChannel createSoundChannel({
    final SoundPosition position = unpanned,
    final double gain = 0.7,
  }) {
    final Source source;
    if (position == unpanned) {
      source = context.createDirectSource();
    } else if (position is SoundPosition3d) {
      source = context.createSource3D(
        x: position.x,
        y: position.y,
        z: position.z,
      );
    } else if (position is SoundPositionAngular) {
      source = context.createAngularPannedSource(
        azimuth: position.azimuth,
        elevation: position.elevation,
      );
    } else if (position is SoundPositionScalar) {
      source = context.createScalarPannedSource(
        panningScalar: position.scalar,
      );
    } else {
      throw StateError('Cannot create a source for $position.');
    }
    return SynthizerSoundChannel(
      backend: this,
      source: source,
    )..gain = gain;
  }

  /// Shutdown the backend.
  @override
  void shutdown() {
    final synthizer = context.synthizer;
    context.destroy();
    synthizer.shutdown();
  }

  /// Create a new reverb.
  @override
  SynthizerBackendReverb createReverb(final ReverbPreset preset) {
    final reverb = context.createGlobalFdnReverb()
      ..meanFreePath.value = preset.meanFreePath
      ..t60.value = preset.t60
      ..lateReflectionsLfRolloff.value = preset.lateReflectionsLfRolloff
      ..lateReflectionsLfReference.value = preset.lateReflectionsLfReference
      ..lateReflectionsHfRolloff.value = preset.lateReflectionsHfRolloff
      ..lateReflectionsHfReference.value = preset.lateReflectionsHfReference
      ..lateReflectionsDiffusion.value = preset.lateReflectionsDiffusion
      ..lateReflectionsModulationDepth.value =
          preset.lateReflectionsModulationDepth
      ..lateReflectionsModulationFrequency.value =
          preset.lateReflectionsModulationFrequency
      ..lateReflectionsDelay.value = preset.lateReflectionsDelay
      ..gain.value = preset.gain;
    return SynthizerBackendReverb(
      backend: this,
      reverb: reverb,
    );
  }

  /// Create a new echo.
  @override
  SynthizerBackendEcho createEcho(final Iterable<EchoTap> taps) =>
      SynthizerBackendEcho(
        backend: this,
        echo: context.createGlobalEcho(),
      )..setTaps(taps);

  /// Get the listener position.
  @override
  ListenerPosition get listenerPosition {
    final position = context.position.value;
    return ListenerPosition(position.x, position.y, position.z);
  }

  /// Set the listener position.
  @override
  set listenerPosition(final ListenerPosition value) =>
      context.position.value = Double3(value.x, value.y, value.z);

  /// Get the listener orientation.
  @override
  ListenerOrientation get listenerOrientation {
    final orientation = context.orientation.value;
    return ListenerOrientation(
      orientation.x1,
      orientation.y1,
      orientation.z1,
      orientation.x2,
      orientation.y2,
      orientation.z2,
    );
  }

  /// Set the listener orientation.
  @override
  set listenerOrientation(final ListenerOrientation value) =>
      context.orientation.value = Double6(
        value.x1,
        value.y1,
        value.z1,
        value.x2,
        value.y2,
        value.z2,
      );

  /// Get the default panner strategy.
  @override
  DefaultPannerStrategy get defaultPannerStrategy {
    final value = context.defaultPannerStrategy.value;
    switch (value) {
      case PannerStrategy.hrtf:
        return DefaultPannerStrategy.hrtf;
      case PannerStrategy.stereo:
        return DefaultPannerStrategy.stereo;
      default:
        throw StateError('Got a panner strategy of $value.');
    }
  }

  /// Set the default panner strategy.
  @override
  set defaultPannerStrategy(final DefaultPannerStrategy value) {
    switch (value) {
      case DefaultPannerStrategy.stereo:
        context.defaultPannerStrategy.value = PannerStrategy.stereo;
        break;
      case DefaultPannerStrategy.hrtf:
        context.defaultPannerStrategy.value = PannerStrategy.hrtf;
        break;
    }
  }
}
