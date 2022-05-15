// ignore_for_file: prefer_final_parameters
/// Provides events relating to playing sounds.
import '../../../notes.dart';
import '../../../wave_types.dart';
import '../../error.dart';
import '../../game.dart';
import '../../json/asset_reference.dart';
import 'automation_fade.dart';
import 'events_base.dart';

/// An event which means a sound should be played.
class PlaySound extends SoundEvent {
  /// Create an event.
  PlaySound({
    required this.game,
    required this.sound,
    required this.channel,
    required this.keepAlive,
    final double gain = 0.7,
    final bool looping = false,
    final double pitchBend = 1.0,
    final int? id,
  })  : _gain = gain,
        _paused = false,
        _looping = looping,
        _pitchBend = pitchBend,
        super(id: id ?? SoundEvent.nextId());

  /// The game to use.
  final Game game;

  /// The reference to the sound.
  final AssetReference sound;

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
  set gain(final double value) {
    _gain = value;
    game.queueSoundEvent(SetSoundGain(id: id!, gain: value));
  }

  bool _looping;

  /// Whether or not this sound should loop.
  bool get looping => _looping;

  /// Set whether or not this sound should loop.
  set looping(final bool value) {
    _looping = value;
    game.queueSoundEvent(SetSoundLooping(id: id!, looping: value));
  }

  bool _paused;

  /// Whether or not this sound is paused.
  bool get paused => _paused;

  /// Pause this sound.
  set paused(final bool value) {
    _paused = value;
    final PauseSound event;
    if (value) {
      event = PauseSound(id!);
    } else {
      event = UnpauseSound(id!);
    }
    game.queueSoundEvent(event);
  }

  double _pitchBend;

  /// Get the pitch bend for this sound.
  ///
  /// A value of `1.0` is "normal".
  double get pitchBend => _pitchBend;

  /// Set [pitchBend].
  set pitchBend(final double value) {
    _pitchBend = value;
    game.queueSoundEvent(SetSoundPitchBend(id: id!, pitchBend: value));
  }

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id, '
      'sound: ${sound.name} '
      '(${sound.encryptionKey == null ? "unencrypted" : "encrypted"} '
      '${sound.type}), '
      'channel: $channel, keep alive: $keepAlive, gain: $_gain, '
      'looping: $_looping, pitch bend: $_pitchBend>';

  /// Fade this sound in or out.
  ///
  /// By default, only [length] is necessary. The [startGain] argument will
  /// default to [gain], and [endGain] to `0.0`, providing a fade out to
  /// complete silence.
  AutomationFade fade({
    required final double length,
    final double endGain = 0.0,
    final double? startGain,
    final double preFade = 0.0,
  }) {
    if (keepAlive == false) {
      throw DeadSound(this);
    }
    final event = AutomationFade(
      game: game,
      id: id!,
      fadeType: FadeType.sound,
      preFade: preFade,
      fadeLength: length,
      startGain: startGain ?? _gain,
      endGain: endGain,
    );
    game.queueSoundEvent(event);
    return event;
  }

  /// Destroy this sound.
  void destroy() {
    if (keepAlive == false) {
      throw DeadSound(this);
    }
    game.queueSoundEvent(DestroySound(id!));
  }
}

/// Pause something.
class PauseEvent extends SoundEvent {
  /// Create an event.
  const PauseEvent(final int id) : super(id: id);

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id>';
}

/// Pause a [PlaySound] event.
class PauseSound extends PauseEvent {
  /// Create an instance.
  const PauseSound(super.id);
}

/// Unpause something.
class UnpauseEvent extends PauseSound {
  /// Create an event.
  const UnpauseEvent(super.id);

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id>';
}

/// Unpause a [PlaySound] instance.
class UnpauseSound extends UnpauseEvent {
  /// Create an instance.
  const UnpauseSound(super.id);
}

/// Destroy something.
class DestroyEvent extends SoundEvent {
  /// Create an event.
  const DestroyEvent(final int id) : super(id: id);

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id>';
}

/// Destroy a [PlaySound] instance.
class DestroySound extends DestroyEvent {
  /// Create an instance.
  const DestroySound(super.id);
}

/// Set the gain for something.
class GainEvent extends SoundEvent {
  /// Create the event.
  const GainEvent({required final int id, required this.gain}) : super(id: id);

  /// The new gain.
  final double gain;

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id, gain: $gain>';
}

/// Set the gain for a sound.
class SetSoundGain extends GainEvent {
  /// Create the instance.
  const SetSoundGain({
    required super.id,
    required super.gain,
  });
}

/// Set whether or not a sound should loop.
class SetSoundLooping extends SoundEvent {
  /// Create an event.
  const SetSoundLooping({required final int id, required this.looping})
      : super(id: id);

  /// Whether or not the sound should loop.
  final bool looping;

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id, looping: $looping>';
}

/// Set the pitch bend for a sound.
class SetSoundPitchBend extends SoundEvent {
  /// Create the event.
  const SetSoundPitchBend({required final int id, required this.pitchBend})
      : super(id: id);

  /// The new pitch bend.
  final double pitchBend;

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id, pitch bend: $pitchBend>';
}

/// Play a wave.
class PlayWave extends SoundEvent {
  /// Create an instance.
  PlayWave({
    required this.game,
    required this.channel,
    required this.waveType,
    final double frequency = a4,
    this.partials = 0,
    final double gain = 0.7,
  })  : _frequency = frequency,
        _gain = gain,
        _paused = false,
        super(id: SoundEvent.nextId());

  /// The game to use.
  final Game game;

  /// The ID of the channel to play through.
  final int channel;

  /// The type of the wave to play.
  final WaveType waveType;

  double _frequency;

  /// Get the frequency to play at.
  double get frequency => _frequency;

  /// Set the frequency to play at.
  set frequency(final double value) {
    _frequency = value;
    game.queueSoundEvent(SetWaveFrequency(id: id!, frequency: value));
  }

  double _gain;

  /// Get the gain for this wave.
  double get gain => _gain;

  /// Set the gain for this wave.
  set gain(final double value) {
    _gain = value;
    game.queueSoundEvent(SetWaveGain(id: id!, gain: value));
  }

  /// The number of partials to use.
  ///
  /// This value is only valid with wave types other than [WaveType.sine].
  final int partials;
  bool _paused;

  /// Returns `true` if this wave is paused.
  bool get paused => _paused;

  /// Pause this sound.
  void pause() {
    _paused = true;
    game.queueSoundEvent(PauseWave(id!));
  }

  /// Unpause this wave.
  void unpause() {
    _paused = false;
    game.queueSoundEvent(UnpauseWave(id!));
  }

  /// Fade this wave in or out.
  ///
  /// By default, only [length] is necessary. The [startGain] argument will
  /// default to [gain], and [endGain] to `0.0`, providing a fade out to
  /// complete silence.
  AutomationFade fade({
    required final double length,
    final double endGain = 0.0,
    final double? startGain,
    final double preFade = 0.0,
  }) {
    final event = AutomationFade(
      game: game,
      id: id!,
      fadeType: FadeType.wave,
      preFade: preFade,
      fadeLength: length,
      startGain: startGain ?? _gain,
      endGain: endGain,
    );
    game.queueSoundEvent(event);
    return event;
  }

  /// Destroy this sound.
  void destroy() {
    game.queueSoundEvent(DestroyWave(id!));
  }

  /// Fade this wave.
  AutomateWaveFrequency automateFrequency({
    required final double length,
    required final double endFrequency,
    final double? startFrequency,
  }) {
    final event = AutomateWaveFrequency(
      id: id!,
      startFrequency: startFrequency ?? _frequency,
      length: length,
      endFrequency: endFrequency,
    );
    game.queueSoundEvent(event);
    return event;
  }

  /// Describe this object.
  @override
  String toString() =>
      '<$runtimeType id: $id, channel: $channel, wave type: $waveType, '
      'partials: $partials>';
}

/// Set the gain for a [PlayWave] instance.
class SetWaveGain extends GainEvent {
  /// Create an instance.
  const SetWaveGain({required super.id, required super.gain});
}

/// Set the frequency for a [PlayWave] instance.
class SetWaveFrequency extends SoundEvent {
  /// Create an instance.
  SetWaveFrequency({required final int id, required this.frequency})
      : super(id: id);

  /// The new frequency.
  final double frequency;

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id, frequency: $frequency>';
}

/// Destroy a [PlayWave] instance.
class DestroyWave extends DestroyEvent {
  /// Create an instance.
  const DestroyWave(super.id);
}

/// Automate the frequency for a [PlayWave] instance.
class AutomateWaveFrequency extends SoundEvent {
  /// Create an instance.
  const AutomateWaveFrequency({
    required final int id,
    required this.startFrequency,
    required this.length,
    required this.endFrequency,
  }) : super(id: id);

  /// The start frequency.
  final double startFrequency;

  /// The length of the automation.
  final double length;

  /// The end frequency.
  final double endFrequency;

  /// Describe this object.
  @override
  String toString() =>
      '<$runtimeType id: $id, start frequency: $startFrequency, '
      'length: $length, end frequency: $endFrequency>';
}

/// Pause a [PlayWave] instance.
class PauseWave extends PauseEvent {
  /// Create an instance.
  const PauseWave(super.id);
}

/// Unpause a [PlayWave] instance.
class UnpauseWave extends UnpauseEvent {
  /// Create an instance.
  const UnpauseWave(super.id);
}
