/// Provides extension methods used by tests.
import 'package:dart_sdl/dart_sdl.dart';

/// The main sdl instance to use.
final sdl = Sdl()..init();

/// Make controller events easier to work with.
ControllerAxisEvent makeControllerAxisEvent(
        GameControllerAxis axis, int value) =>
    ControllerAxisEvent(
        sdl: sdl,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        joystickId: 1,
        axis: axis,
        value: value);

/// Get a keyboard event.
KeyboardEvent makeKeyboardEvent(ScanCode scanCode, KeyCode keyCode,
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
TextInputEvent makeTextInputEvent(String text) =>
    TextInputEvent(sdl, DateTime.now().millisecondsSinceEpoch, text);

/// Make a controller button event.
ControllerButtonEvent makeControllerButtonEvent(GameControllerButton button,
        {PressedState state = PressedState.pressed}) =>
    ControllerButtonEvent(
        sdl: sdl,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        joystickId: 1,
        button: button,
        state: state);
