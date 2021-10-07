/// Provides the [Editor] class.
import 'package:dart_sdl/dart_sdl.dart';

import '../game.dart';
import 'level.dart';

/// A level for editing text.
class Editor extends Level {
  /// Create an instance.
  Editor(Game game, {this.text = ''}) : super(game);

  /// The current text of this editor.
  String text;

  /// Handle text editing events from SDL.
  @override
  void handleSdlEvent(Event event) {
    if (event is TextInputEvent) {
      game.outputText(event.text);
      text += event.text;
    }
  }
}
