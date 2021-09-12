/// Provides the [AutomationFade] class.
import '../../game.dart';
import '../../json/sound_reference.dart';
import 'events_base.dart';

/// Cancel an automation fade.
class CancelAutomationFade extends SoundEvent {
  /// Create an instance.
  CancelAutomationFade(
      {required int id, required this.channel, required this.sound})
      : super(id);

  /// The channel that holds the sound whose fade we want to cancel.
  final int channel;

  /// The ID of the sound whose fade should be cancelled.
  final SoundReference sound;
}

/// An event to fade a sound in or out.
class AutomationFade extends CancelAutomationFade {
  /// Create an instance.
  AutomationFade(
      {required this.game,
      required int channel,
      required SoundReference sound,
      required this.fadeLength,
      required this.startGain,
      required this.endGain})
      : super(id: SoundEvent.nextId(), channel: channel, sound: sound);

  /// The game this fade is associated with.
  final Game game;

  /// The length of the fade in seconds.
  final double fadeLength;

  /// The gain at the start of the fade.
  final double startGain;

  /// The gain at the end of the fade.
  final double endGain;

  /// Cancel this fade.
  CancelAutomationFade cancel() {
    final event = CancelAutomationFade(id: id, channel: channel, sound: sound);
    game.queueSoundEvent(event);
    return event;
  }
}
