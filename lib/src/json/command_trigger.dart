/// Provides classes related to command triggers.
import 'package:dart_sdl/dart_sdl.dart';
import 'package:json_annotation/json_annotation.dart';

import '../command.dart';

part 'command_trigger.g.dart';

/// A keyboard key that must be held down in order for a [Command] to be
/// triggered.
@JsonSerializable()
class CommandKeyboardKey {
  /// Create an instance.
  const CommandKeyboardKey(
    this.scanCode, {
    this.shiftKey = false,
    this.controlKey = false,
    this.altKey = false,
  });

  /// Create an instance from a JSON object.
  factory CommandKeyboardKey.fromJson(Map<String, dynamic> json) =>
      _$CommandKeyboardKeyFromJson(json);

  /// The keyboard key which must be used to trigger this command.
  final ScanCode scanCode;

  /// The shift key.
  final bool shiftKey;

  /// The control key.
  final bool controlKey;

  /// The alt key.
  final bool altKey;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$CommandKeyboardKeyToJson(this);

  /// Return a printable string of this key.
  String toPrintableString({
    String controlKeyName = 'ctrl',
    String shiftKeyName = 'shift',
    String altKeyName = 'alt',
    String Function(ScanCode scanCode)? getScanCodeString,
    String separator = '+',
  }) {
    final keys = <String>[];
    if (controlKey) {
      keys.add(controlKeyName);
    }
    if (shiftKey) {
      keys.add(shiftKeyName);
    }
    if (altKey) {
      keys.add(altKeyName);
    }
    if (getScanCodeString == null) {
      keys.add(scanCode.name);
    } else {
      keys.add(getScanCodeString(scanCode));
    }
    return keys.join(separator);
  }

  @override
  String toString() => '<$runtimeType ${toPrintableString()}>';
}

/// A trigger which can fire a [Command].
@JsonSerializable()
class CommandTrigger {
  /// Create an instance.
  const CommandTrigger(
      {required this.name,
      required this.description,
      this.keyboardKey,
      this.button});

  /// Create an instance from a JSON object.
  factory CommandTrigger.fromJson(Map<String, dynamic> json) =>
      _$CommandTriggerFromJson(json);

  /// Create a basic trigger.
  ///
  /// Creating instances can be quite verbose, so this method exists to make
  /// that process shorter.
  factory CommandTrigger.basic(
          {required String name,
          required String description,
          ScanCode? scanCode,
          GameControllerButton? button}) =>
      CommandTrigger(
          name: name,
          description: description,
          button: button,
          keyboardKey:
              (scanCode == null) ? null : CommandKeyboardKey(scanCode));

  /// The name of the command which this trigger will send.
  final String name;

  /// The description of this command.
  final String description;

  /// The keyboard key which must be held down in order for this command to be
  /// triggered.
  final CommandKeyboardKey? keyboardKey;

  /// The games controller button which must be pressed to trigger this command.
  final GameControllerButton? button;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$CommandTriggerToJson(this);
}
