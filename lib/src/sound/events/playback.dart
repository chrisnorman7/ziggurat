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
      this.gain = 0.7,
      this.looping = false})
      : super(id);

  /// The reference to the sound.
  final SoundReference sound;

  /// The position of this sound.
  final SoundPosition position;

  /// The ID of a reverb that was previously created.
  final int? reverb;

  /// The gain of this sound.
  final double gain;

  /// Whether or not this sound should loop.
  final bool looping;
}

/// Pause a sound.
class PauseSound extends SoundEvent {
  /// Create an event.
  const PauseSound(int id) : super(id);
}

/// Unpause a sound.
class UnpauseSound extends SoundEvent {
  /// Create an event.
  const UnpauseSound(int id) : super(id);
}

/// Destroy a sound.
class DestroySound extends SoundEvent {
  /// Create an event.
  const DestroySound(int id) : super(id);
}

/// Set the gain for a sound.
class SetGain extends SoundEvent {
  /// Create the event.
  const SetGain({required int id, required this.gain}) : super(id);

  /// The new gain.
  final double gain;
}

/// Set whether or not a sound should loop.
class SetLoop extends SoundEvent {
  /// Create an event.
  SetLoop({required int id, required this.looping}) : super(id);

  /// Whether or not the sound should loop.
  final bool looping;
}
