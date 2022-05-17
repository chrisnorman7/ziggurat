/// Provides extension methods used by tests.
import 'package:dart_sdl/dart_sdl.dart';

/// Make controller events easier to work with.
ControllerAxisEvent makeControllerAxisEvent(
  final Sdl sdl,
  final GameControllerAxis axis,
  final int value,
) =>
    ControllerAxisEvent(
      sdl: sdl,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      joystickId: 1,
      axis: axis,
      value: value,
    );

/// Get a keyboard event.
KeyboardEvent makeKeyboardEvent(
  final Sdl sdl,
  final ScanCode scanCode,
  final KeyCode keyCode, {
  final PressedState state = PressedState.released,
  final Set<KeyMod> modifiers = const <KeyMod>{},
}) =>
    KeyboardEvent(
      sdl,
      DateTime.now().millisecondsSinceEpoch,
      0,
      state,
      false,
      KeyboardKey(
        scancode: scanCode,
        keycode: keyCode,
        modifiers: modifiers,
      ),
    );

/// Make a text input event.
TextInputEvent makeTextInputEvent(final Sdl sdl, final String text) =>
    TextInputEvent(sdl, DateTime.now().millisecondsSinceEpoch, text);

/// Make a controller button event.
ControllerButtonEvent makeControllerButtonEvent(
  final Sdl sdl,
  final GameControllerButton button, {
  final PressedState state = PressedState.released,
}) =>
    ControllerButtonEvent(
      sdl: sdl,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      joystickId: 1,
      button: button,
      state: state,
    );
