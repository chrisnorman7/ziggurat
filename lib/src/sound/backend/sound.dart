/// Provides the [Sound] class.
import 'sound_backend.dart';

/// A sound that has been played by a [SoundBackend] instance.
abstract class Sound {
  /// Whether or not to keep this sound alive.
  bool get keepAlive;

  /// Get the gain for this sound.
  double get gain;

  /// Set the gain for this sound.
  set gain(final double value);

  /// Whether or not this sound should loop.
  bool get looping;

  /// Set [looping].
  set looping(final bool value);

  /// Get the pitch bend for this sound.
  double get pitchBend;

  /// Set the pitch bend for this sound.
  set pitchBend(final double value);

  /// Get the position of the play head in this sound.
  double get position;

  /// Set the playback position.
  set position(final double value);

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
