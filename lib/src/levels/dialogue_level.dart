/// Provides the [DialogueLevel] class.
import 'package:dart_sdl/dart_sdl.dart';

import '../game.dart';
import '../json/ambiance.dart';
import '../json/message.dart';
import '../json/random_sound.dart';
import '../sound/events/playback.dart';
import '../sound/events/sound_channel.dart';
import 'level.dart';

/// A level that shows a series of [Message] instances to the player, allowing
/// them to skip between them.
class DialogueLevel extends Level {
  /// Create an instance.
  DialogueLevel({
    required Game game,
    required this.messages,
    required this.onDone,
    this.progressScanCode,
    this.progressControllerButton,
    this.position = 0,
    this.soundChannel,
    List<Ambiance>? ambiances,
    List<RandomSound>? randomSounds,
  })  : assert(
            progressScanCode != null || progressControllerButton != null,
            'Both `ProgressControllerButton` and `progressScanCode` cannot be '
            '`null`.'),
        assert(messages.where((element) => element.keepAlive == false).isEmpty,
            'All messages must have their `keepAlive` value set to `true`.'),
        super(game: game, ambiances: ambiances, randomSounds: randomSounds);

  /// The list of messages to progress through.
  final List<Message> messages;

  /// The function that will be called when the [messages] list has been
  /// exhausted.
  final void Function() onDone;

  /// The current position in the [messages] list.
  ///
  /// This value will be incremented by the [progress] method.
  int position;

  /// The sound channel to output sounds through.
  final SoundChannel? soundChannel;

  /// The currently playing sound.
  PlaySound? _sound;

  /// The currently-playing sound.
  PlaySound? get sound => _sound;

  /// The scancode that allows progressing through the [messages] list.
  final ScanCode? progressScanCode;

  /// The game controller button that lets the player progress through the
  /// [messages] list.
  final GameControllerButton? progressControllerButton;

  /// Progress through the list of [messages].
  ///
  /// If the focus moves past the end of the list, then [onDone] is called.
  void progress() {
    if (position >= messages.length) {
      onDone();
    } else {
      _sound = game.outputMessage(messages.elementAt(position),
          oldSound: _sound, soundChannel: soundChannel);
      position++;
    }
  }

  @override
  void onPush() {
    super.onPush();
    progress();
  }

  @override
  void onPop(double? fadeLength) {
    super.onPop(fadeLength);
    final sound = _sound;
    if (sound != null) {
      if (fadeLength == null) {
        sound.destroy();
      } else {
        game.callAfter(
          runAfter: (fadeLength * 1000).round(),
          func: sound.destroy,
        );
      }
    }
    _sound = null;
  }

  @override
  void handleSdlEvent(Event event) {
    final button = progressControllerButton;
    final scanCode = progressScanCode;
    if (button != null &&
        event is ControllerButtonEvent &&
        event.state == PressedState.pressed &&
        event.button == button) {
      progress();
    } else if (scanCode != null &&
        event is KeyboardEvent &&
        event.state == PressedState.pressed &&
        event.repeat == false &&
        event.key.modifiers.isEmpty &&
        event.key.scancode == scanCode) {
      progress();
    }
  }
}
