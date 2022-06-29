/// Provides events relating to the playing of [SimpleSound]s.
import '../../../sound.dart';
import '../../game.dart';
import '../../json/asset_reference.dart';

/// An event for playing a simple one-off sound.
class SimpleSound<T extends SoundPosition> extends SoundEvent {
  /// Create an instance.
  SimpleSound({
    required this.game,
    required this.sound,
    required final T position,
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

  double _pitchBend;

  /// Get the pitch bend for this sound.
  double get pitchBend => _pitchBend;

  /// Set the pitch bend for this sound.
  set pitchBend(final double value) {
    _pitchBend = value;
    game.queueSoundEvent(SimpleSoundPitchBend(id: id!, pitchBend: value));
  }
}

/// An event for setting the position of a [SimpleSound] instance.
class SimpleSoundPosition<T extends SoundPosition> extends SoundEvent {
  /// Create an instance.
  const SimpleSoundPosition({
    required final int id,
    required this.position,
  }) : super(id: id);

  /// The position to set.
  final T position;
}

/// An event for setting the gain of a [SimpleSound] instance.
class SimpleSoundGain extends GainEvent {
  /// Create an instance.
  const SimpleSoundGain({
    required super.id,
    required super.gain,
  });
}

/// An event for setting the reverb id of a [SimpleSound] instance.
class SimpleSoundReverb extends SetSoundChannelReverb {
  /// Create an instance.
  const SimpleSoundReverb({
    required super.id,
    required super.reverb,
  });
}

/// Set the pitch bend for a [SimpleSound] instance.
class SimpleSoundPitchBend extends SetSoundPitchBend {
  /// Create an instance.
  const SimpleSoundPitchBend({
    required super.id,
    required super.pitchBend,
  });
}
