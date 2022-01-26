/// Provides the [Editor] class.
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';

import '../controller_axis_dispatcher.dart';
import '../game.dart';
import '../json/ambiance.dart';
import '../json/random_sound.dart';
import 'level.dart';

/// A level for editing text.
class Editor extends Level {
  /// Create an instance.
  ///
  /// The [upDownAxis] value decides which axis will call the [moveUp] and
  /// [moveDown] methods.
  ///
  /// The [leftRightAxis] value decides which axis will call the [moveLeft] and
  /// [moveRight] methods.
  ///
  /// The [typeAxis] value decides which axis will call the [type] method.
  ///
  /// The [backspaceAxis] value decides which axis will call the [backspace]
  /// method.
  ///
  /// The [controllerAxisSensitivity] value decides how sensitive the axis
  /// controls are.
  ///
  /// The [controllerMovementSpeed] value decides how regularly axis controllers
  /// can be used.
  ///
  /// The [ambiances] and [randomSounds] lists are passed directly to the
  /// [Level] constructor.
  Editor({
    required Game game,
    required this.onDone,
    this.text = '',
    this.onCancel,
    this.controllerAlphabet = 'abcdefghijklmnopqrstuvwxyz,.'
        '1234567890'
        r'!"£$%^&*(){}~\/'
        "-=_+@'",
    this.leftButton = GameControllerButton.dpadLeft,
    this.rightButton = GameControllerButton.dpadRight,
    this.upButton = GameControllerButton.dpadUp,
    this.downButton = GameControllerButton.dpadDown,
    this.typeButton = GameControllerButton.rightshoulder,
    this.shiftButton = GameControllerButton.a,
    this.doneScanCode = ScanCode.SCANCODE_RETURN,
    this.doneButton = GameControllerButton.y,
    this.cancelScanCode = ScanCode.SCANCODE_ESCAPE,
    this.cancelButton = GameControllerButton.leftshoulder,
    this.spaceButton = GameControllerButton.b,
    this.backspaceScanCode = ScanCode.SCANCODE_BACKSPACE,
    this.backspaceButton = GameControllerButton.x,
    GameControllerAxis upDownAxis = GameControllerAxis.lefty,
    GameControllerAxis leftRightAxis = GameControllerAxis.rightx,
    GameControllerAxis typeAxis = GameControllerAxis.triggerright,
    GameControllerAxis backspaceAxis = GameControllerAxis.triggerleft,
    int controllerMovementSpeed = 400,
    double controllerAxisSensitivity = 0.5,
    List<Ambiance>? ambiances,
    List<RandomSound>? randomSounds,
  })  : _shiftPressed = false,
        _currentPosition = 0,
        super(game: game, ambiances: ambiances, randomSounds: randomSounds) {
    controllerAxisDispatcher = ControllerAxisDispatcher({
      upDownAxis: (double value) {
        if (value > 0) {
          moveDown();
        } else {
          moveUp();
        }
      },
      leftRightAxis: (double value) {
        if (value > 0) {
          moveRight();
        } else {
          moveLeft();
        }
      },
      typeAxis: (double value) => type(),
      backspaceAxis: (double value) => backspace()
    },
        axisSensitivity: controllerAxisSensitivity,
        functionInterval: controllerMovementSpeed);
  }

  /// The current text of this editor.
  String text;

  /// The method to be called when the enter key is pressed.
  final void Function(String value) onDone;

  /// The function to call when the escape key is pressed.
  ///
  /// If this value is `null`, then it will not be possible to cancel this
  /// editor.
  final void Function()? onCancel;

  /// The alphabet used when entering text from a controller.
  final String controllerAlphabet;

  /// The button used for moving up in the letter grid.
  final GameControllerButton upButton;

  /// The button used for moving down in the letter grid.
  final GameControllerButton downButton;

  /// The button used for moving left in the grid.
  final GameControllerButton leftButton;

  /// The button used for moving right in the letter grid.
  final GameControllerButton rightButton;

  /// The button used for typing the currently-focussed letter in the letter
  /// grid.
  final GameControllerButton typeButton;

  /// The button for adding capital letters.
  final GameControllerButton shiftButton;

  /// The key that will call [onDone].
  final ScanCode doneScanCode;

  /// The button that will call [onDone].
  final GameControllerButton doneButton;

  /// The key that will call [cancel].
  final ScanCode cancelScanCode;

  /// The button that will call [cancel].
  final GameControllerButton cancelButton;

  /// The button that will insert a space character.
  final GameControllerButton spaceButton;

  /// The key that will call the [backspace] method.
  final ScanCode backspaceScanCode;

  /// The button that will call the [backspace] method.
  final GameControllerButton backspaceButton;

  /// The controller axis dispatcher used by this instance.
  late final ControllerAxisDispatcher controllerAxisDispatcher;

  /// Whether or not the next selected letter should be capitalised.
  bool _shiftPressed;

  /// The current position in the letter grid.
  int _currentPosition;

  /// The currently focussed letter.
  String get currentLetter {
    final letter = controllerAlphabet[_currentPosition];
    if (_shiftPressed) {
      return letter.toUpperCase();
    }
    return letter;
  }

  /// Return a char with appropriate conversions applied.
  ///
  /// This method is used whenever a single character needs to be printed.
  ///
  /// It should be used to replace single characters like " " with something
  /// more meaningful (like the word "space").
  String convertChar(String char) => char == ' ' ? 'space' : char;

  /// Output some text.
  void outputText(String string) => game.outputText(string);

  /// Add [value] to [text].
  void appendText(String value) {
    text += value;
    outputText(convertChar(value));
  }

  /// Cancel this editor.
  ///
  /// This method has no effect if [onCancel] is `null`.
  void cancel() {
    final f = onCancel;
    if (f != null) {
      f();
    }
  }

  /// Delete the previous letter.
  void backspace() {
    if (text.isEmpty) {
      return outputText('Start of line.');
    }
    final char = text[text.length - 1];
    outputText('Deleted ${convertChar(char)}.');
    text = text.substring(0, text.length - 1);
  }

  /// Toggle the state of the shift key.
  void toggleShift(bool value) {
    _shiftPressed = value;
    outputText('Shift ${value ? "enabled" : "disabled"}.');
  }

  /// Type the currently focussed letter.
  void type() => appendText(currentLetter);

  /// Move by the given [amount] in the letter grid.
  void moveInLetterGrid(int amount) {
    _currentPosition += amount;
    if (_currentPosition < 0) {
      _currentPosition = 0;
    } else if (_currentPosition >= controllerAlphabet.length) {
      _currentPosition = controllerAlphabet.length - 1;
    }
    outputText(convertChar(currentLetter));
  }

  /// Move up in the letter grid.
  void moveUp() => moveInLetterGrid(-sqrt(controllerAlphabet.length).round());

  /// Move down in the letter grid.
  void moveDown() => moveInLetterGrid(sqrt(controllerAlphabet.length).round());

  /// Move left in the letter grid.
  void moveLeft() => moveInLetterGrid(-1);

  /// Move right in the letter grid.
  void moveRight() => moveInLetterGrid(1);

  /// Handle text editing events from SDL.
  @override
  void handleSdlEvent(Event event) {
    if (event is TextInputEvent) {
      appendText(event.text);
    } else if (event is KeyboardEvent &&
        event.state == PressedState.pressed &&
        event.key.modifiers.isEmpty) {
      final scanCode = event.key.scancode;
      if (scanCode == doneScanCode) {
        onDone(text);
      } else if (scanCode == cancelScanCode) {
        cancel();
      } else if (scanCode == backspaceScanCode) {
        backspace();
      }
    } else if (event is ControllerButtonEvent) {
      final button = event.button;
      if (button == shiftButton) {
        toggleShift(event.state == PressedState.pressed);
      } else if (event.state == PressedState.pressed) {
        if (button == typeButton) {
          type();
        } else if (button == upButton) {
          moveUp();
        } else if (button == downButton) {
          moveDown();
        } else if (button == leftButton) {
          moveLeft();
        } else if (button == rightButton) {
          moveRight();
        } else if (button == doneButton) {
          onDone(text);
        } else if (button == cancelButton) {
          cancel();
        } else if (button == backspaceButton) {
          backspace();
        } else if (button == spaceButton) {
          appendText(' ');
        }
      }
    } else if (event is ControllerAxisEvent) {
      controllerAxisDispatcher.handleAxisValue(event.axis, event.smallValue);
    }
  }
}
