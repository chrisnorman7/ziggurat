/// Provides the [Editor] class.
import 'package:dart_sdl/dart_sdl.dart';

import '../game.dart';
import 'level.dart';

/// A level for editing text.
class Editor extends Level {
  /// Create an instance.
  Editor(Game game, this.onDone, {this.text = '', this.onCancel}) : super(game);

  /// The current text of this editor.
  String text;

  /// The method to be called when the enter key is pressed.
  final void Function(String value) onDone;

  /// The function to call when the escape key is pressed.
  ///
  /// If this value is `null`, then it will not be possible to cancel this
  /// editor.
  final void Function()? onCancel;

  /// Handle text editing events from SDL.
  @override
  void handleSdlEvent(Event event) {
    if (event is TextInputEvent) {
      final value = event.text;
      game.outputText(value);
      text += value;
    } else if (event is KeyboardEvent &&
        event.state == PressedState.released &&
        event.key.modifiers.isEmpty) {
      if (event.key.scancode == ScanCode.SCANCODE_RETURN) {
        onDone(text);
      } else if (event.key.scancode == ScanCode.SCANCODE_ESCAPE) {
        final f = onCancel;
        if (f != null) {
          f();
        }
      }
    }
  }
}
