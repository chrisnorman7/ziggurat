import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  final game = Game('Edit Test');
  final sdl = Sdl();
  group('Editor', () {
    test('Initialisation', () {
      String? text;

      final editor = Editor(game, (String value) => text = value);
      expect(text, isNull);
      expect(editor.text, isEmpty);
    });
    test('Handle text', () {
      final editor = Editor(game, print)
        ..handleSdlEvent(KeyboardEvent(
            sdl,
            DateTime.now().millisecondsSinceEpoch,
            0,
            PressedState.pressed,
            false,
            KeyboardKey(
                scancode: ScanCode.SCANCODE_0,
                keycode: KeyCode.keycode_0,
                modifiers: [])));
      expect(editor.text, isEmpty);
      editor.handleSdlEvent(
          TextInputEvent(sdl, DateTime.now().millisecondsSinceEpoch, 'hello'));
      expect(editor.text, equals('hello'));
      editor.handleSdlEvent(
          TextInputEvent(sdl, DateTime.now().millisecondsSinceEpoch, ' world'));
      expect(editor.text, equals('hello world'));
    });
    test('.onDone', () {
      String? text;
      final editor = Editor(game, (value) {
        text = value;
      })
        ..handleSdlEvent(TextInputEvent(
            sdl, DateTime.now().millisecondsSinceEpoch, 'Testing things.'));
      expect(text, isNull);
      editor.handleSdlEvent(KeyboardEvent(
          sdl,
          DateTime.now().millisecondsSinceEpoch,
          0,
          PressedState.pressed,
          false,
          KeyboardKey(
              scancode: ScanCode.SCANCODE_RETURN,
              keycode: KeyCode.keycode_RETURN,
              modifiers: [])));
      expect(text, isNull);
      editor.handleSdlEvent(KeyboardEvent(
          sdl,
          DateTime.now().millisecondsSinceEpoch,
          0,
          PressedState.released,
          false,
          KeyboardKey(
              scancode: ScanCode.SCANCODE_RETURN,
              keycode: KeyCode.keycode_RETURN,
              modifiers: [])));
      expect(text, equals(editor.text));
    });
    test('.onCancel', () {
      var editor = Editor(game, print);
      final escapeEvent = KeyboardEvent(
          sdl,
          DateTime.now().millisecondsSinceEpoch,
          0,
          PressedState.released,
          false,
          KeyboardKey(
              scancode: ScanCode.SCANCODE_ESCAPE,
              keycode: KeyCode.keycode_ESCAPE,
              modifiers: []));
      editor.handleSdlEvent(escapeEvent);
      var cancelled = 0;
      editor = Editor(game, print, onCancel: () => cancelled++)
        ..handleSdlEvent(KeyboardEvent(
            sdl,
            DateTime.now().millisecondsSinceEpoch,
            0,
            PressedState.pressed,
            false,
            KeyboardKey(
                scancode: escapeEvent.key.scancode,
                keycode: escapeEvent.key.keycode,
                modifiers: [])));
      expect(cancelled, isZero);
      editor.handleSdlEvent(escapeEvent);
      expect(cancelled, equals(1));
    });
  });
}
