/// Provides the [AutomationFade] and [CancelAutomationFade] classes.
import '../../game.dart';
import 'events_base.dart';
import 'playback.dart';
import 'simple_sound.dart';

/// The type of an [AutomationFade] instance.
enum FadeType {
  /// Fade out a [PlaySound] instance.
  sound,

  /// Fade out a [PlayWave] instance.
  wave,

  /// Fade out a [PlaySimpleSound] instance.
  simpleSound,
}

/// Cancel an automation fade.
class CancelAutomationFade extends SoundEvent {
  /// Create an instance.
  const CancelAutomationFade({required final int id, required this.fadeType})
      : super(id: id);

  /// The type of this fade.
  final FadeType fadeType;

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id, fade type: $fadeType>';
}

/// An event to fade a sound in or out.
class AutomationFade extends CancelAutomationFade {
  /// Create an instance.
  const AutomationFade({
    required this.game,
    required super.id,
    required super.fadeType,
    required this.preFade,
    required this.fadeLength,
    required this.startGain,
    required this.endGain,
  });

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
  void cancel() =>
      game.queueSoundEvent(CancelAutomationFade(id: id!, fadeType: fadeType));

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id ($fadeType), from: $startGain, '
      'pre fade: $preFade, length: '
      '$fadeLength, end gain: $endGain>';
}
