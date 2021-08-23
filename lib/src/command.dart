/// Provides the [Command] class.

/// A command which can be executed by the player, or by a simulation.
class Command {
  /// Create a command.
  Command({this.interval, this.onStart, this.onUndo, this.onStop})
      : nextRun = 0,
        isRunning = false;

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

  /// The time this command will run next.
  int nextRun;

  /// Whether or not this command is running.
  bool isRunning;
}
