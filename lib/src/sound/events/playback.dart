/// Provides events relating to playing sounds.
import '../../error.dart';
import '../../game.dart';
import '../../json/sound_reference.dart';
import 'automation_fade.dart';
import 'events_base.dart';

/// An event which means a sound should be played.
class PlaySound extends SoundEvent {
  /// Create an event.
  PlaySound(
      {required this.game,
      required this.sound,
      required this.channel,
      required this.keepAlive,
      double gain = 0.7,
      bool looping = false,
      double pitchBend = 1.0})
      : _gain = gain,
        _paused = false,
        _looping = looping,
        _pitchBend = pitchBend,
        super(SoundEvent.nextId());

  /// The game to use.
  final Game game;

  /// The reference to the sound.
  final SoundReference sound;

  /// The channel this sound should play through.
  final int channel;

  /// Whether or not this sound should be kept around.
  ///
  /// If this value is `true`, then the [destroy] method must be used to destroy
  /// this sound.
  ///
  /// If this value is `false`, the sound will go away on its own, and calling
  /// [destroy] will result in
  /// [DeadSound] being thrown.
  final bool keepAlive;

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

  double _pitchBend;

  /// Get the pitch bend for this sound.
  ///
  /// A value of `1.0` is "normal".
  double get pitchBend => _pitchBend;

  /// Set [pitchBend].
  set pitchBend(double value) {
    _pitchBend = value;
    game.queueSoundEvent(SetSoundPitchBend(id: id, pitchBend: value));
  }

  /// Fade this sound in or out.
  ///
  /// By default, only [length] is necessary. The [startGain] argument will
  /// default to [gain], and [endGain] to `0.0`, providing a fade out to
  /// complete silence.
  AutomationFade fade(
      {required double length,
      double endGain = 0.0,
      double? startGain,
      double preFade = 0.0}) {
    if (keepAlive == false) {
      throw DeadSound(this);
    }
    final event = AutomationFade(
        game: game,
        id: id,
        preFade: preFade,
        fadeLength: length,
        startGain: startGain ?? _gain,
        endGain: endGain);
    game.queueSoundEvent(event);
    return event;
  }

  /// Destroy this sound.
  void destroy() {
    if (keepAlive == false) {
      throw DeadSound(this);
    }
    final event = DestroySound(id);
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
  const DestroySound(int id) : super(id);
}

/// Set the gain for a sound.
class SetSoundGain extends SoundEvent {
  /// Create the event.
  const SetSoundGain({required int id, required this.gain}) : super(id);

  /// The new gain.
  final double gain;
}

/// Set whether or not a sound should loop.
class SetLoop extends SoundEvent {
  /// Create an event.
  const SetLoop({required int id, required this.looping}) : super(id);

  /// Whether or not the sound should loop.
  final bool looping;
}

/// Set the pitch bend for a sound.
class SetSoundPitchBend extends SoundEvent {
  /// Create the event.
  const SetSoundPitchBend({required int id, required this.pitchBend})
      : super(id);

  /// The new pitch bend.
  final double pitchBend;
}
