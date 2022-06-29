/// Provides events relating to the playing of [PlaySimpleSound]s.
import '../../../sound.dart';
import '../../error.dart';
import '../../game.dart';
import '../../json/asset_reference.dart';

/// An event for playing a simple one-off sound.
class PlaySimpleSound<T extends SoundPosition> extends SoundEvent {
  /// Create an instance.
  PlaySimpleSound({
    required this.game,
    required this.sound,
    required final T position,
    required this.keepAlive,
    final double gain = 0.7,
    final double pitchBend = 1.0,
    final int? reverb,
  })  : _gain = gain,
        _pitchBend = pitchBend,
        _position = position,
        _reverb = reverb,
        super(id: SoundEvent.nextId());

  /// The game to use for sending events.
  final Game game;

  /// The asset to play.
  final AssetReference sound;

  T _position;

  /// The position of this sound.
  T get position => _position;

  /// Set the position for this sound.
  set position(final T value) {
    _position = value;
    game.queueSoundEvent(SimpleSoundPosition(id: id!, position: value));
  }

  /// Whether or not to keep this sound alive.
  final bool keepAlive;

  double _gain;

  /// Get the gain for this sound.
  double get gain => _gain;

  /// Set the gain for this sound.
  set gain(final double value) {
    _gain = value;
    game.queueSoundEvent(
      SimpleSoundGain(
        id: id!,
        gain: value,
      ),
    );
  }

  int? _reverb;

  /// The ID of the [CreateReverb] instance to play this sound through.
  int? get reverb => _reverb;

  /// Set the reverb for this sound.
  set reverb(final int? value) {
    _reverb = value;
    game.queueSoundEvent(SimpleSoundReverb(id: id!, reverb: value));
  }

  int? _echo;

  /// Get the ID of the echo this sound should have applied.
  int? get echo => _echo;

  /// Set the ID of the echo this sound should play through.
  set echo(final int? value) {
    _echo = value;
    game.queueSoundEvent(SimpleSoundEcho(id: id!, echo: value));
  }

  double _pitchBend;

  /// Get the pitch bend for this sound.
  double get pitchBend => _pitchBend;

  /// Set the pitch bend for this sound.
  set pitchBend(final double value) {
    _pitchBend = value;
    game.queueSoundEvent(SimpleSoundPitchBend(id: id!, pitchBend: value));
  }

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
      throw DeadSimpleSound(this);
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
}

/// An event for setting the position of a [PlaySimpleSound] instance.
class SimpleSoundPosition<T extends SoundPosition> extends SoundEvent {
  /// Create an instance.
  const SimpleSoundPosition({
    required final int id,
    required this.position,
  }) : super(id: id);

  /// The position to set.
  final T position;
}

/// An event for setting the gain of a [PlaySimpleSound] instance.
class SimpleSoundGain extends GainEvent {
  /// Create an instance.
  const SimpleSoundGain({
    required super.id,
    required super.gain,
  });
}

/// An event for setting the reverb id of a [PlaySimpleSound] instance.
class SimpleSoundReverb extends SetSoundChannelReverb {
  /// Create an instance.
  const SimpleSoundReverb({
    required super.id,
    required super.reverb,
  });
}

/// Set the pitch bend for a [PlaySimpleSound] instance.
class SimpleSoundPitchBend extends SetSoundPitchBend {
  /// Create an instance.
  const SimpleSoundPitchBend({
    required super.id,
    required super.pitchBend,
  });
}

/// An event for setting the echo for a [PlaySimpleSound] event.
class SimpleSoundEcho extends SetSoundChannelEcho {
  /// Create an instance.
  const SimpleSoundEcho({
    required super.id,
    required super.echo,
  });
}
