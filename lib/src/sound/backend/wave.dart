import 'sound_backend.dart';

/// A wave that has been created by a [SoundBackend] instance.
abstract class Wave {
  /// Set the frequency for this wave.
  void setFrequency(final double frequency, {final double? time});

  /// The gain for this sound.
  double get gain;

  /// Pause this sound.
  void pause();

  /// Unpause this sound.
  void unpause();

  /// Cancel any fade that has begun for this sound.
  void cancelFade();

  /// Fade this sound.
  void fade({
    required final double length,
    final double endGain = 0.0,
    final double? startGain,
    final double preFade = 0.0,
  });

  /// Destroy this sound.
  void destroy();
}
