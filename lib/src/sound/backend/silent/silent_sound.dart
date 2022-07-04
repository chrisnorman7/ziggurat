/// Provides the [SilentSound] class.
import '../sound.dart';
import 'silent_sound_channel.dart';

/// A silent sound.
///
/// If a tree falls in a forest, but nobody is there to hear it, does it truly
/// make a sound?
class SilentSound implements Sound {
  /// Create an instance.
  SilentSound({
    required this.channel,
    this.gain = 0.7,
    this.looping = false,
    this.pitchBend = 1.0,
    this.position = 0.0,
    this.keepAlive = false,
  });

  @override
  final SilentSoundChannel channel;

  @override
  double gain;

  @override
  bool looping;

  @override
  double pitchBend;

  @override
  double position;

  @override
  void cancelFade() {}

  @override
  void destroy() {}

  @override
  void fade({
    required final double length,
    final double endGain = 0.0,
    final double? startGain,
    final double preFade = 0.0,
  }) {}

  @override
  final bool keepAlive;

  @override
  void pause() {}

  @override
  void unpause() {}
}
