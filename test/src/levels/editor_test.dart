import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/src/sound/backend/silent/silent_sound_backend.dart';
import 'package:ziggurat/ziggurat.dart';

import '../../helpers.dart';

void main() {
  final sdl = Sdl();
  final game = Game(
    title: 'Edit Test',
    sdl: sdl,
    soundBackend: SilentSoundBackend(),
  );
  group('Editor', () {
    test('Initialisation', () {
      String? text;
      final editor = Editor(game: game, onDone: (final value) => text = value);
      expect(text, isNull);
      expect(editor.text, isEmpty);
      expect(editor.onCancel, isNull);
      expect(editor.controllerAxisDispatcher.functionInterval, equals(400));
      expect(editor.controllerAxisDispatcher.axisSensitivity, equals(0.5));
    });
    test('Handle text', () {
      final editor = Editor(game: game, onDone: print)
        ..handleSdlEvent(
          makeKeyboardEvent(sdl, ScanCode.digit0, KeyCode.digit0),
        );
      expect(editor.text, isEmpty);
      editor.handleSdlEvent(makeTextInputEvent(sdl, 'hello'));
      expect(editor.text, equals('hello'));
      editor.handleSdlEvent(
        makeControllerButtonEvent(
          sdl,
          editor.spaceButton,
          state: PressedState.pressed,
        ),
      );
      expect(editor.text, equals('hello '));
      editor.handleSdlEvent(makeTextInputEvent(sdl, 'world'));
      expect(editor.text, equals('hello world'));
    });
    test('.onDone', () {
      String? text;
      final editor = Editor(
        game: game,
        onDone: (final value) {
          text = value;
        },
      )..handleSdlEvent(makeTextInputEvent(sdl, 'Testing things.'));
      expect(text, isNull);
      editor.handleSdlEvent(
        makeKeyboardEvent(sdl, ScanCode.return_, KeyCode.return_),
      );
      expect(text, isNull);
      editor.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          ScanCode.return_,
          KeyCode.return_,
          state: PressedState.pressed,
        ),
      );
      expect(text, equals(editor.text));
      text = '';
      editor.handleSdlEvent(
        makeControllerButtonEvent(
          sdl,
          editor.doneButton,
          state: PressedState.pressed,
        ),
      );
      expect(text, equals(editor.text));
    });
    test('.onCancel', () {
      var editor = Editor(game: game, onDone: print);
      final escapeEvent = makeKeyboardEvent(
        sdl,
        ScanCode.escape,
        KeyCode.escape,
        state: PressedState.pressed,
      );
      editor.handleSdlEvent(escapeEvent);
      var cancelled = 0;
      editor = Editor(game: game, onDone: print, onCancel: () => cancelled++)
        ..handleSdlEvent(
          makeKeyboardEvent(
            sdl,
            escapeEvent.key.scancode,
            escapeEvent.key.keycode,
          ),
        );
      expect(cancelled, isZero);
      editor.handleSdlEvent(escapeEvent);
      expect(cancelled, equals(1));
      editor.handleSdlEvent(
        makeControllerButtonEvent(
          sdl,
          editor.cancelButton,
          state: PressedState.pressed,
        ),
      );
      expect(cancelled, equals(2));
    });
    test('.backspace', () {
      final editor = Editor(game: game, onDone: print);
      final backspaceEvent = makeKeyboardEvent(
        sdl,
        ScanCode.backspace,
        KeyCode.backspace,
        state: PressedState.pressed,
      );
      editor.handleSdlEvent(backspaceEvent);
      expect(editor.text, isEmpty);
      editor
        ..appendText('Testing.')
        ..handleSdlEvent(backspaceEvent);
      expect(editor.text, equals('Testing'));
      editor.handleSdlEvent(
        makeControllerButtonEvent(
          sdl,
          editor.backspaceButton,
          state: PressedState.pressed,
        ),
      );
      expect(editor.text, equals('Testin'));
    });
    test('Axes', () {
      const minValue = -32768;
      const maxValue = 32767;
      final editor =
          Editor(game: game, onDone: print, controllerMovementSpeed: 0);
      expect(editor.controllerAxisDispatcher.axisSensitivity, equals(0.5));
      expect(editor.controllerAxisDispatcher.functionInterval, isZero);
      editor.handleSdlEvent(
        makeControllerAxisEvent(
          sdl,
          GameControllerAxis.triggerright,
          maxValue,
        ),
      );
      expect(editor.text, equals('a'));
      expect(editor.currentLetter, equals(editor.controllerAlphabet[0]));
      editor.handleSdlEvent(
        makeControllerAxisEvent(sdl, GameControllerAxis.rightx, maxValue),
      );
      expect(editor.currentLetter, equals(editor.controllerAlphabet[1]));
      editor.handleSdlEvent(
        makeControllerAxisEvent(
          sdl,
          GameControllerAxis.triggerright,
          maxValue,
        ),
      );
      expect(editor.text, equals('ab'));
      editor.handleSdlEvent(
        makeControllerAxisEvent(
          sdl,
          GameControllerAxis.triggerleft,
          maxValue,
        ),
      );
      expect(editor.text, equals('a'));
      editor.handleSdlEvent(
        makeControllerAxisEvent(sdl, GameControllerAxis.rightx, minValue),
      );
      expect(editor.currentLetter, equals(editor.controllerAlphabet[0]));
      editor.handleSdlEvent(
        makeControllerAxisEvent(sdl, GameControllerAxis.lefty, maxValue),
      );
      expect(
        editor.currentLetter,
        equals(
          editor.controllerAlphabet[
              sqrt(editor.controllerAlphabet.length).round()],
        ),
      );
      editor.handleSdlEvent(
        makeControllerAxisEvent(sdl, GameControllerAxis.rightx, minValue),
      );
      expect(
        editor.currentLetter,
        equals(
          editor.controllerAlphabet[
              sqrt(editor.controllerAlphabet.length).round() - 1],
        ),
      );
      editor.handleSdlEvent(
        makeControllerAxisEvent(sdl, GameControllerAxis.lefty, minValue),
      );
      expect(editor.currentLetter, equals(editor.controllerAlphabet[0]));
    });
    test('Shift key', () {
      final editor = Editor(game: game, onDone: print);
      editor
        ..handleSdlEvent(
          makeControllerButtonEvent(
            sdl,
            editor.shiftButton,
            state: PressedState.pressed,
          ),
        )
        ..handleSdlEvent(
          makeControllerButtonEvent(
            sdl,
            editor.typeButton,
            state: PressedState.pressed,
          ),
        );
      expect(editor.text, equals('A'));
      editor.handleSdlEvent(
        makeControllerButtonEvent(
          sdl,
          editor.typeButton,
          state: PressedState.pressed,
        ),
      );
      expect(editor.text, equals('AA'));
      editor
        ..handleSdlEvent(makeControllerButtonEvent(sdl, editor.shiftButton))
        ..handleSdlEvent(
          makeControllerButtonEvent(
            sdl,
            editor.typeButton,
            state: PressedState.pressed,
          ),
        );
      expect(editor.text, equals('AAa'));
    });
  });
}
