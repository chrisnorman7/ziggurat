/// Provides events relating to playing sounds.
import '../../json/sound_reference.dart';
import 'events_base.dart';
import 'sound_position.dart';

/// An event which means a sound should be played.
class PlaySound extends SoundEvent {
  /// Create an event.
  const PlaySound(
      {required this.sound,
      required this.position,
      required int id,
      this.reverb,
      this.gain = 0.7})
      : super(id);

  /// The reference to the sound.
  final SoundReference sound;

  /// The position of this sound.
  final SoundPosition position;

  /// The ID of a reverb that was previously created.
  final int? reverb;

  /// The gain of this sound.
  final double gain;
}

/// Pause a sound.
class PauseSound extends SoundEvent {
  /// Create an event.
  const PauseSound(int id) : super(id);
}

/// Unpause a sound.
class UnpauseSound extends PauseSound {
  /// Create an event.
  const UnpauseSound(int id) : super(id);
}

/// Destroy a sound.
class DestroySound extends PauseSound {
  /// Create an event.
  const DestroySound(int id) : super(id);
}

/// Set the gain for a sound.
class SetGain extends PauseSound {
  /// Create the event.
  const SetGain({required int id, required this.gain}) : super(id);

  /// The new gain.
  final double gain;
}
