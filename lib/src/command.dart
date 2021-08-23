/// Provides the [Command] class.

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
  int? interval;

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
