/// Provides the [SynthizerWave] class.
import 'package:dart_synthizer/dart_synthizer.dart';

import '../wave.dart';
import 'synthizer_sound_backend.dart';

/// A synthizer wave.
class SynthizerWave implements Wave {
  /// Create an instance.
  const SynthizerWave({
    required this.backend,
    required this.generator,
  });

  /// The backend to use.
  final SynthizerSoundBackend backend;

  /// The generator to play through.
  final FastSineBankGenerator generator;

  /// The context to use.
  Context get context => backend.context;

  /// Cancel any fade out started by calls to the [fade] method.
  @override
  void cancelFade() {
    generator.gain.clear();
  }

  /// Destroy [generator].
  @override
  void destroy() {
    generator.destroy();
  }

  /// Fade the [generator].
  @override
  void fade({
    required final double length,
    final double endGain = 0.0,
    final double? startGain,
    final double preFade = 0.0,
  }) {
    final startTime = context.currentTime.value;
    final endTime = startTime + length;
    generator.gain.automate(
      startTime: startTime,
      startValue: startGain ?? gain,
      endTime: endTime,
      endValue: endGain,
    );
  }

  /// Get the [generator] gain.
  @override
  double get gain => generator.gain.value;

  /// Set the [generator] gain.
  set gain(final double value) => generator.gain.value = value;

  /// Pause the [generator].
  @override
  void pause() {
    generator.pause();
  }

  /// Set the frequency for [generator].
  @override
  void setFrequency(final double frequency, {final double? time}) {
    if (time == null) {
      generator.frequency.value = frequency;
    } else {
      final startTime = context.currentTime.value;
      final endTime = startTime + time;
      generator.frequency.automate(
        startTime: startTime,
        startValue: generator.frequency.value,
        endTime: endTime,
        endValue: frequency,
      );
    }
  }

  /// Unpause [generator].
  @override
  void unpause() {
    generator.play();
  }
}
