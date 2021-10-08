/// Provides extension methods used by tests.
import 'package:dart_sdl/dart_sdl.dart';

/// Make controller events easier to work with.
ControllerAxisEvent makeControllerAxisEvent(
        Sdl sdl, GameControllerAxis axis, int value) =>
    ControllerAxisEvent(
        sdl: sdl,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        joystickId: 1,
        axis: axis,
        value: value);

/// Get a keyboard event.
KeyboardEvent makeKeyboardEvent(Sdl sdl, ScanCode scanCode, KeyCode keyCode,
        {PressedState state = PressedState.released,
        List<KeyMod>? modifiers}) =>
    KeyboardEvent(
        sdl,
        DateTime.now().millisecondsSinceEpoch,
        0,
        state,
        false,
        KeyboardKey(
            scancode: scanCode, keycode: keyCode, modifiers: modifiers ?? []));

/// Make a text input event.
TextInputEvent makeTextInputEvent(Sdl sdl, String text) =>
    TextInputEvent(sdl, DateTime.now().millisecondsSinceEpoch, text);

/// Make a controller button event.
ControllerButtonEvent makeControllerButtonEvent(
        Sdl sdl, GameControllerButton button,
        {PressedState state = PressedState.pressed}) =>
    ControllerButtonEvent(
        sdl: sdl,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        joystickId: 1,
        button: button,
        state: state);
