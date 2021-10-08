import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

import 'helpers.dart';

void main() {
  final game = Game('Edit Test');
  final sdl = Sdl();
  group('Editor', () {
    test('Initialisation', () {
      String? text;
      final editor = Editor(game, (String value) => text = value);
      expect(text, isNull);
      expect(editor.text, isEmpty);
      expect(editor.onCancel, isNull);
    });
    test('Handle text', () {
      final editor = Editor(game, print)
        ..handleSdlEvent(
            makeKeyboardEvent(sdl, ScanCode.SCANCODE_0, KeyCode.keycode_0));
      expect(editor.text, isEmpty);
      editor.handleSdlEvent(makeTextInputEvent(sdl, 'hello'));
      expect(editor.text, equals('hello'));
      editor.handleSdlEvent(makeControllerButtonEvent(sdl, editor.spaceButton));
      expect(editor.text, equals('hello '));
      editor.handleSdlEvent(makeTextInputEvent(sdl, 'world'));
      expect(editor.text, equals('hello world'));
    });
    test('.onDone', () {
      String? text;
      final editor = Editor(game, (value) {
        text = value;
      })
        ..handleSdlEvent(makeTextInputEvent(sdl, 'Testing things.'));
      expect(text, isNull);
      editor.handleSdlEvent(makeKeyboardEvent(
          sdl, ScanCode.SCANCODE_RETURN, KeyCode.keycode_RETURN,
          state: PressedState.pressed));
      expect(text, isNull);
      editor.handleSdlEvent(makeKeyboardEvent(
          sdl, ScanCode.SCANCODE_RETURN, KeyCode.keycode_RETURN));
      expect(text, equals(editor.text));
      text = '';
      editor.handleSdlEvent(makeControllerButtonEvent(sdl, editor.doneButton));
      expect(text, equals(editor.text));
    });
    test('.onCancel', () {
      var editor = Editor(game, print);
      final escapeEvent = makeKeyboardEvent(
          sdl, ScanCode.SCANCODE_ESCAPE, KeyCode.keycode_ESCAPE);
      editor.handleSdlEvent(escapeEvent);
      var cancelled = 0;
      editor = Editor(game, print, onCancel: () => cancelled++)
        ..handleSdlEvent(makeKeyboardEvent(
            sdl, escapeEvent.key.scancode, escapeEvent.key.keycode,
            state: PressedState.pressed));
      expect(cancelled, isZero);
      editor.handleSdlEvent(escapeEvent);
      expect(cancelled, equals(1));
      editor
          .handleSdlEvent(makeControllerButtonEvent(sdl, editor.cancelButton));
      expect(cancelled, equals(2));
    });
    test('.backspace', () {
      final editor = Editor(game, print);
      final backspaceEvent = makeKeyboardEvent(
          sdl, ScanCode.SCANCODE_BACKSPACE, KeyCode.keycode_BACKSPACE);
      editor.handleSdlEvent(backspaceEvent);
      expect(editor.text, isEmpty);
      editor
        ..appendText('Testing.')
        ..handleSdlEvent(backspaceEvent);
      expect(editor.text, equals('Testing'));
      editor.handleSdlEvent(makeControllerButtonEvent(
        sdl,
        editor.backspaceButton,
      ));
      expect(editor.text, equals('Testin'));
    });
    test('Axes', () {
      const minValue = -32768;
      const maxValue = 32767;
      final editor = Editor(game, print, controllerMovementSpeed: 0);
      expect(editor.controllerAxisDispatcher.axisSensitivity, equals(0.5));
      expect(editor.controllerAxisDispatcher.functionInterval, isZero);
      editor.handleSdlEvent(makeControllerAxisEvent(
          sdl, GameControllerAxis.triggerright, maxValue));
      expect(editor.text, equals('a'));
      expect(editor.currentLetter, equals(editor.controllerAlphabet[0]));
      editor.handleSdlEvent(
          makeControllerAxisEvent(sdl, GameControllerAxis.rightx, maxValue));
      expect(editor.currentLetter, equals(editor.controllerAlphabet[1]));
      editor.handleSdlEvent(makeControllerAxisEvent(
          sdl, GameControllerAxis.triggerright, maxValue));
      expect(editor.text, equals('ab'));
      editor.handleSdlEvent(makeControllerAxisEvent(
          sdl, GameControllerAxis.triggerleft, maxValue));
      expect(editor.text, equals('a'));
      editor.handleSdlEvent(
          makeControllerAxisEvent(sdl, GameControllerAxis.rightx, minValue));
      expect(editor.currentLetter, equals(editor.controllerAlphabet[0]));
      editor.handleSdlEvent(
          makeControllerAxisEvent(sdl, GameControllerAxis.lefty, maxValue));
      expect(
          editor.currentLetter,
          equals(editor.controllerAlphabet[
              sqrt(editor.controllerAlphabet.length).round()]));
      editor.handleSdlEvent(
          makeControllerAxisEvent(sdl, GameControllerAxis.rightx, minValue));
      expect(
          editor.currentLetter,
          equals(editor.controllerAlphabet[
              sqrt(editor.controllerAlphabet.length).round() - 1]));
      editor.handleSdlEvent(
          makeControllerAxisEvent(sdl, GameControllerAxis.lefty, minValue));
      expect(editor.currentLetter, equals(editor.controllerAlphabet[0]));
    });
    test('Shift key', () {
      final editor = Editor(game, print);
      editor
        ..handleSdlEvent(makeControllerButtonEvent(sdl, editor.shiftButton))
        ..handleSdlEvent(makeControllerButtonEvent(sdl, editor.typeButton));
      expect(editor.text, equals('A'));
      editor.handleSdlEvent(makeControllerButtonEvent(sdl, editor.typeButton));
      expect(editor.text, equals('AA'));
      editor
        ..handleSdlEvent(makeControllerButtonEvent(sdl, editor.shiftButton,
            state: PressedState.released))
        ..handleSdlEvent(makeControllerButtonEvent(sdl, editor.typeButton));
      expect(editor.text, equals('AAa'));
    });
  });
}
