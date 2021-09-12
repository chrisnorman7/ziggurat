/// Provides the [AutomationFade] class.
import '../../game.dart';
import 'events_base.dart';

/// Cancel an automation fade.
class CancelAutomationFade extends SoundEvent {
  /// Create an instance.
  CancelAutomationFade(int id) : super(id);
}

/// An event to fade a sound in or out.
class AutomationFade extends CancelAutomationFade {
  /// Create an instance.
  AutomationFade(
      {required this.game,
      required int id,
      required this.preFade,
      required this.fadeLength,
      required this.startGain,
      required this.endGain})
      : super(id);

  /// The game this fade is associated with.
  final Game game;

  /// The number of seconds to elapse before applying this fade.
  final double preFade;

  /// The length of the fade in seconds.
  final double fadeLength;

  /// The gain at the start of the fade.
  final double startGain;

  /// The gain at the end of the fade.
  final double endGain;

  /// Cancel this fade.
  void cancel() => game.queueSoundEvent(CancelAutomationFade(id));
}
