/// Provides the [SceneLevel] class.
import 'package:dart_sdl/dart_sdl.dart';

import '../game.dart';
import '../json/ambiance.dart';
import '../json/message.dart';
import '../json/random_sound.dart';
import '../sound/events/playback.dart';
import '../sound/events/sound_channel.dart';
import 'level.dart';

/// A level that plays a cutscene.
class SceneLevel extends Level {
  /// Create an instance.
  ///
  /// Both [ambiances] and [randomSounds] will be passed to the [Level]
  /// constructor.
  SceneLevel(
      {required Game game,
      required this.message,
      required this.onDone,
      this.duration,
      this.skipScanCode,
      this.skipControllerButton,
      this.soundChannel,
      List<Ambiance>? ambiances,
      List<RandomSound>? randomSounds})
      : assert(
            duration != null ||
                skipControllerButton != null ||
                skipScanCode != null,
            'At least one of `duration`, `skipControllerButton`, or '
            '`skipScanCode` must not be null.'),
        super(game, ambiances: ambiances, randomSounds: randomSounds) {
    assert(
        message.keepAlive == true,
        'If `keepAlive` is not `true`, then `onPop` will not function '
        'properly.');
  }

  /// The message to play.
  ///
  /// The [Message.keepAlive] property must be `true`.
  final Message message;

  /// The sound channel to play the [message] sound through.
  ///
  /// If this value is `null`, then [Game.interfaceSounds] will be used.
  final SoundChannel? soundChannel;

  /// The number of milliseconds to run this scene for.
  ///
  /// If this value is `null`, the scene will not automatically skip, and
  /// either [skipControllerButton] or [skipScanCode] must be not `null`.
  final int? duration;

  /// The callback to be run when the scene has finished.
  final void Function() onDone;

  /// The scancode that will prematurely end this scene.
  ///
  /// If this value is `null`, it will not be possible to skip this scene.
  final ScanCode? skipScanCode;

  /// The game controller button that will prematurely end this scene.
  ///
  /// If this value is `null`, it will not be possible to skip this scene.
  final GameControllerButton? skipControllerButton;

  /// The playing sound (if any).
  PlaySound? _sound;

  /// The currently-playing sound.
  PlaySound? get sound => _sound;

  @override
  void onPush() {
    super.onPush();
    _sound = game.outputMessage(message,
        soundChannel: soundChannel, oldSound: _sound);
    if (duration != null) {
      game.registerTask(duration!, onDone);
    }
  }

  @override
  void onPop(double? fadeLength) {
    super.onPop(fadeLength);
    _sound?.destroy();
  }

  /// Skip this scene.
  void skip() {
    game.unregisterTask(onDone);
    onDone();
  }

  @override
  void handleSdlEvent(Event event) {
    if (event is KeyboardEvent &&
        event.repeat == false &&
        event.key.modifiers.isEmpty &&
        event.key.scancode == skipScanCode &&
        event.state == PressedState.pressed) {
      skip();
    } else if (event is ControllerButtonEvent &&
        event.button == skipControllerButton &&
        event.state == PressedState.pressed) {
      skip();
    }
  }
}
