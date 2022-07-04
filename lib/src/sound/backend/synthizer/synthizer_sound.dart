import 'package:dart_synthizer/dart_synthizer.dart';

import '../../../../sound.dart';

/// A sound that has been played by a [SynthizerSoundBackend] instance.
class SynthizerSound implements Sound {
  /// Create an instance.
  const SynthizerSound({
    required this.backend,
    required this.channel,
    required this.keepAlive,
    required this.source,
    required this.generator,
  });

  /// The backend to use.
  final SynthizerSoundBackend backend;

  /// The channel this sound is playing through.
  @override
  final SynthizerSoundChannel channel;

  /// The source to play through.
  final Source source;

  /// The generator to play through.
  final Generator generator;

  /// The context that both [source] and [generator] are attached to.
  Context get context => backend.context;

  /// Whether to keep this sound alive or not.
  @override
  final bool keepAlive;

  /// Cancel any fade started with [fade].
  @override
  void cancelFade() {
    generator.gain.clear();
  }

  /// Destroy [generator].
  @override
  void destroy() {
    if (!keepAlive) {
      throw StateError('This sound was not kept alive.');
    }
    generator.destroy();
  }

  /// Fade [generator].
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
      startValue: startGain ?? generator.gain.value,
      endTime: endTime,
      endValue: endGain,
    );
  }

  /// Get the gain for [generator].
  @override
  double get gain => generator.gain.value;

  /// Set the gain of [generator].
  @override
  set gain(final double value) => generator.gain.value = value;

  /// Get the looping status of [generator].
  @override
  bool get looping => generator.looping.value;

  /// Set the looping state of [generator].
  @override
  set looping(final bool value) => generator.looping.value = value;

  /// Pause [generator].
  @override
  void pause() {
    generator.pause();
  }

  /// Get the pitch bend for [generator].
  @override
  double get pitchBend => generator.pitchBend.value;

  /// Set the pitch bend of [generator].
  @override
  set pitchBend(final double value) => generator.pitchBend.value = value;

  /// Get the position of [generator].
  ///
  /// If [generator] is not a [BufferGenerator], [StateError] will be thrown.
  @override
  double get position {
    final g = generator;
    if (g is BufferGenerator) {
      return g.playbackPosition.value;
    }
    throw StateError('Cannot get the playback position for $g.');
  }

  /// Set the position of [generator].
  ///
  /// If [generator] is not a [BufferGenerator], [StateError] will be thrown.
  @override
  set position(final double value) {
    final g = generator;
    if (g is BufferGenerator) {
      g.playbackPosition.value = value;
    } else {
      throw StateError('Cannot set the playback position of $g.');
    }
  }

  /// Unpause [generator].
  @override
  void unpause() {
    generator.play();
  }
}
