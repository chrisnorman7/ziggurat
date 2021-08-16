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
  CommandKeyboardKey(this.scanCode,
      {this.shiftKey = false, this.controlKey = false, this.altKey = false});

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
}

/// A trigger which can fire a [Command].
@JsonSerializable()
class CommandTrigger {
  /// Create an instance.
  CommandTrigger({this.keyboardKey, this.button});

  /// Create an instance from a JSON object.
  factory CommandTrigger.fromJson(Map<String, dynamic> json) =>
      _$CommandTriggerFromJson(json);

  /// The keyboard key which must be held down in order for this command to be
  /// triggered.
  final CommandKeyboardKey? keyboardKey;

  /// The games controller button which must be pressed to trigger this command.
  final GameControllerButton? button;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$CommandTriggerToJson(this);
}
