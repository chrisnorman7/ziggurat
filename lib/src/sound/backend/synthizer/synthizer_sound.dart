import 'package:dart_synthizer/dart_synthizer.dart';

import '../../../../sound.dart';

/// A sound that has been played by a [SynthizerSoundBackend] instance.
class SynthizerSound implements Sound {
  /// Create an instance.
  const SynthizerSound({
    required this.backend,
    required this.channel,
    required this.keepAlive,
    required this.generator,
  });

  /// The backend to use.
  final SynthizerSoundBackend backend;

  /// The channel this sound is playing through.
  @override
  final SynthizerSoundChannel channel;

  /// The source to play through.
  Source get source => channel.source;

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
    checkDeadSound();
    generator.gain.clear();
  }

  /// Destroy [generator].
  @override
  void destroy() {
    checkDeadSound();
    generator.destroy();
  }

  /// Throws [StateError] if [keepAlive] is `false`.
  void checkDeadSound() {
    if (!keepAlive) {
      throw StateError('Dead sound.');
    }
  }

  /// Fade [generator].
  @override
  void fade({
    required final double length,
    final double endGain = 0.0,
    final double? startGain,
    final double preFade = 0.0,
  }) {
    checkDeadSound();
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
  double get gain {
    checkDeadSound();
    return generator.gain.value;
  }

  /// Set the gain of [generator].
  @override
  set gain(final double value) {
    checkDeadSound();
    generator.gain.value = value;
  }

  /// Get the looping status of [generator].
  @override
  bool get looping {
    checkDeadSound();
    return generator.looping.value;
  }

  /// Set the looping state of [generator].
  @override
  set looping(final bool value) {
    checkDeadSound();
    generator.looping.value = value;
  }

  /// Pause [generator].
  @override
  void pause() {
    checkDeadSound();
    generator.pause();
  }

  /// Unpause [generator].
  @override
  void unpause() {
    checkDeadSound();
    generator.play();
  }

  /// Get the pitch bend for [generator].
  @override
  double get pitchBend {
    checkDeadSound();
    return generator.pitchBend.value;
  }

  /// Set the pitch bend of [generator].
  @override
  set pitchBend(final double value) {
    checkDeadSound();
    generator.pitchBend.value = value;
  }

  /// Get the position of [generator].
  ///
  /// If [generator] is not a [BufferGenerator], [StateError] will be thrown.
  @override
  double get position {
    checkDeadSound();
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
    checkDeadSound();
    final g = generator;
    if (g is BufferGenerator) {
      g.playbackPosition.value = value;
    } else {
      throw StateError('Cannot set the playback position of $g.');
    }
  }
}
