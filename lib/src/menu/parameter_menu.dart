/// Provides the [ParameterMenu] and [ParameterMenuParameter] classes.
import 'package:dart_sdl/dart_sdl.dart';

import '../../menus.dart';
import '../game.dart';
import '../json/ambiance.dart';
import '../json/message.dart';
import '../json/music.dart';
import '../json/random_sound.dart';
import '../tasks/task.dart';

/// The default message for [ParameterMenuParameter].
const _defaultMessage = Message(text: "If you can see this, there's a bug.");

/// A parameter for use in a [ParameterMenu].
class ParameterMenuParameter extends MenuItem {
  /// Create an instance.
  const ParameterMenuParameter({
    required this.getLabel,
    required this.increaseValue,
    required this.decreaseValue,
  }) : super(_defaultMessage, menuItemLabel);

  /// The function to get the label of the [MenuItem] that represents this
  /// parameter.
  final Message Function() getLabel;

  /// The function which is used to increase the value of this parameter.
  final TaskFunction increaseValue;

  /// The function which is used to decrease the value of this parameter.
  final TaskFunction decreaseValue;

  /// Show the message provided by [getLabel].
  @override
  void onFocus(covariant ParameterMenu menu) {
    final message = getLabel();
    menu.oldSound = menu.game.outputMessage(message, oldSound: menu.oldSound);
  }
}

/// A menu for editing parameters.
class ParameterMenu extends Menu {
  /// Create an instance.
  ParameterMenu({
    required Game game,
    required Message title,
    required List<ParameterMenuParameter> parameters,
    this.decreaseValueButton = GameControllerButton.dpadLeft,
    this.decreaseValueScanCode = ScanCode.SCANCODE_LEFT,
    this.increaseValueButton = GameControllerButton.dpadRight,
    this.increaseValueScanCode = ScanCode.SCANCODE_RIGHT,
    TaskFunction? onCancel,
    Music? music,
    List<Ambiance>? ambiances,
    List<RandomSound>? randomSounds,
  }) : super(
          game: game,
          title: title,
          items: List<MenuItem>.from(parameters),
          music: music,
          ambiances: ambiances,
          randomSounds: randomSounds,
          onCancel: onCancel,
        );

  /// The scan code for decreasing values.
  final ScanCode decreaseValueScanCode;

  /// The button to decrease values.
  final GameControllerButton decreaseValueButton;

  /// The scancode for increasing values.
  final ScanCode increaseValueScanCode;

  /// The button for increasing values.
  final GameControllerButton increaseValueButton;

  /// Handle SDL values.
  @override
  void handleSdlEvent(Event event) {
    final item = currentMenuItem;
    if (item is ParameterMenuParameter) {
      if (event is KeyboardEvent &&
          event.state == PressedState.pressed &&
          event.repeat == false &&
          event.key.modifiers.isEmpty) {
        final scanCode = event.key.scancode;
        if (scanCode == increaseValueScanCode) {
          item.increaseValue();
        } else if (scanCode == decreaseValueScanCode) {
          item.decreaseValue();
        }
      }
      if (event is ControllerButtonEvent &&
          event.state == PressedState.pressed) {
        if (event.button == decreaseValueButton) {
          item.decreaseValue();
        } else if (event.button == increaseValueButton) {
          item.increaseValue();
        }
      }
    }
    super.handleSdlEvent(event);
  }
}
