/// Provides the [SoundChannel] class.
import '../../game.dart';
import '../../json/sound_reference.dart';
import 'events_base.dart';

/// A channel for playing sounds through.
class SoundChannel extends SoundEvent {
  /// Create a channel.
  SoundChannel(
      {required this.game,
      required int id,
      this.position = unpanned,
      this.reverb,
      double gain = 0.7})
      : _gain = gain,
        super(id);

  /// The game object to use for this channel.
  final Game game;

  /// The position of this channel.
  final SoundPosition position;

  /// The ID of a reverb that was previously created.
  final int? reverb;

  double _gain;

  /// The gain of this channel.
  double get gain => _gain;

  /// Set the gain of this channel.
  set gain(double value) {
    _gain = value;
    game.queueSoundEvent(SetSoundChannelGain(id: id, gain: value));
  }

  /// Play a sound through this channel.
  PlaySound playSound(SoundReference sound,
      {double gain = 0.7, bool looping = false, bool keepAlive = false}) {
    final event = PlaySound(
        game: game,
        sound: sound,
        keepAlive: keepAlive,
        id: SoundEvent.nextId(),
        gain: gain,
        looping: looping,
        channel: id);
    game.queueSoundEvent(event);
    return event;
  }

  /// Destroy this channel.
  void destroy() => game.queueSoundEvent(DestroySoundChannel(id));
}

/// Destroy a [SoundChannel] instance.
class DestroySoundChannel extends SoundEvent {
  /// Create an event.
  DestroySoundChannel(int id) : super(id);
}
