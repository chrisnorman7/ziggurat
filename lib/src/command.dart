/// Provides classes related to commands.
import 'package:dart_sdl/dart_sdl.dart';

import 'json/command_trigger.dart';

/// A command which can be executed by the player, or by a simulation.
class Command {
  /// Create a command.
  Command(
      {required this.name,
      required this.description,
      this.interval,
      this.onStart,
      this.onUndo,
      this.onStop})
      : lastRun = 0,
        nextRun = 0;

  /// The short name of this command.
  ///
  /// This name will be used in the trigger map.
  final String name;

  /// A one-line description for this command.
  ///
  /// This value will be used in help menus.
  final String description;

  /// The number of milliseconds which must elapse between uses of this command.
  ///
  /// If this value is `null`, then this command will never repeat.
  final int? interval;

  /// The function which will run when this command is used.
  final void Function()? onStart;

  /// The function which will run when this command is no longer being used.
  final void Function()? onStop;

  /// The function which will undo the [onStart] function.
  final void Function()? onUndo;

  /// The time this command was last used.
  int lastRun;

  /// The time this command will run next.
  int nextRun;
}

/// A class which represents a collection of commands.
class CommandHandler {
  /// Create a handler.
  CommandHandler()
      : _commands = {},
        _triggerMap = {};

  final Map<String, Command> _commands;

  /// The commands supported by this handler.
  Map<String, Command> get commands => _commands;

  final Map<CommandTrigger, Command> _triggerMap;

  /// The trigger map for this handler.
  Map<CommandTrigger, Command> get triggerMap => _triggerMap;

  /// Register a command.
  void registerCommand(Command command, CommandTrigger defaultTrigger) {
    _commands[command.name] = command;
    _triggerMap[defaultTrigger] = command;
  }

  /// Run the given [command].
  ///
  /// The [when] argument will be used to decide whether or not the command
  /// should run, based on the command's [Command.interval] value.
  void startCommand(Command command, int when) {
    final onRun = command.onStart;
    if (onRun == null) {
      return;
    }
    final interval = command.interval;
    final lastRun = command.lastRun;
    if (interval == null || ((when - lastRun) >= interval)) {
      onRun();
      command.lastRun = when;
      if (interval != null) {
        command.nextRun = when + interval;
      }
    }
  }

  /// Stop a command from repeating.
  void stopCommand(Command command) {
    final onStop = command.onStop;
    if (onStop != null) {
      onStop();
    }
    command.nextRun = 0;
  }

  /// Handle the [event] keyboard event.
  void handleKeyboardEvent(KeyboardEvent event) {
    for (final entry in _triggerMap.entries) {
      final trigger = entry.key;
      final command = entry.value;
      final keyboardKey = trigger.keyboardKey;
      if (keyboardKey == null) {
        continue;
      }
      final key = event.key;
      if (key.alt == keyboardKey.altKey &&
          key.shift == keyboardKey.shiftKey &&
          key.ctrl == keyboardKey.controlKey &&
          key.scancode == keyboardKey.scanCode) {
        switch (event.state) {
          case PressedState.pressed:
            startCommand(command, event.timestamp);
            break;
          case PressedState.released:
            stopCommand(command);
            break;
        }
      }
    }
  }

  /// Handle the game controller button event [event].
  void handleButtonEvent(ControllerButtonEvent event) {
    for (final entry in _triggerMap.entries) {
      final trigger = entry.key;
      final command = entry.value;
      if (trigger.button == event.button) {
        switch (event.state) {
          case PressedState.pressed:
            startCommand(command, event.timestamp);
            break;
          case PressedState.released:
            stopCommand(command);
            break;
        }
      }
    }
  }
}
