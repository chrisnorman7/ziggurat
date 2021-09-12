/// Provides the [AutomationFade] class.
import 'events_base.dart';

/// An event to fade a sound in or out.
class AutomationFade extends SoundEvent {
  /// Create an instance.
  AutomationFade(
      {required int id,
      required this.fadeLength,
      required this.startGain,
      required this.endGain})
      : super(id);

  /// The length of the fade in seconds.
  final double fadeLength;

  /// The gain at the start of the fade.
  final double startGain;

  /// The gain at the end of the fade.
  final double endGain;
}
