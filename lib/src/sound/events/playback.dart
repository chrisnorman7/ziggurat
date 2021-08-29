/// Provides events relating to playing sounds.
import '../../game.dart';
import '../../json/sound_reference.dart';
import 'events_base.dart';
import 'sound_channel.dart';

/// An event which means a sound should be played.
class PlaySound extends SoundEvent {
  /// Create an event.
  PlaySound(
      {required this.game,
      required this.sound,
      required this.channel,
      required int id,
      double gain = 0.7,
      bool looping = false})
      : _gain = gain,
        _paused = false,
        _looping = looping,
        super(id);

  /// The game to use.
  final Game game;

  /// The reference to the sound.
  final SoundReference sound;

  /// The channel this sound should play through.
  final int channel;

  double _gain;

  /// The gain of this sound.
  double get gain => _gain;

  /// Set the gain for this sound.
  set gain(double value) {
    _gain = value;
    game.queueSoundEvent(SetSoundGain(id: id, gain: value));
  }

  bool _looping;

  /// Whether or not this sound should loop.
  bool get looping => _looping;

  /// Set whether or not this sound should loop.
  set looping(bool value) {
    _looping = value;
    game.queueSoundEvent(SetLoop(id: id, looping: value));
  }

  bool _paused;

  /// Whether or not this sound is paused.
  bool get paused => _paused;

  /// Pause this sound.
  set paused(bool value) {
    _paused = value;
    final PauseSound event;
    if (value) {
      event = PauseSound(id);
    } else {
      event = UnpauseSound(id);
    }
    game.queueSoundEvent(event);
  }

  /// Destroy this sound.
  void destroy() {
    final event = DestroySound(id: id, channel: channel);
    game.queueSoundEvent(event);
  }
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
class DestroySound extends SoundEvent {
  /// Create an event.
  const DestroySound({required int id, required this.channel}) : super(id);

  /// The ID of the channel the sound was previously registered on.
  final int channel;
}

/// Set the gain for a sound.
class SetSoundGain extends SoundEvent {
  /// Create the event.
  const SetSoundGain({required int id, required this.gain}) : super(id);

  /// The new gain.
  final double gain;
}

/// Set the gain for a [SoundChannel].
class SetSoundChannelGain extends SetSoundGain {
  /// Create an event.
  const SetSoundChannelGain({required int id, required double gain})
      : super(id: id, gain: gain);
}

/// Set whether or not a sound should loop.
class SetLoop extends SoundEvent {
  /// Create an event.
  SetLoop({required int id, required this.looping}) : super(id);

  /// Whether or not the sound should loop.
  final bool looping;
}
