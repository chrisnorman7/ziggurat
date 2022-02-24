/// Provides the [Command] class.

/// A command which can be executed by the player, or by a simulation.
class Command {
  /// Create a command.
  const Command({
    this.interval,
    this.onStart,
    this.onUndo,
    this.onStop,
  });

  /// The number of milliseconds which must elapse between uses of this command.
  ///
  /// If this value is `null`, then this command will never repeat.
  final int? interval;

  /// The function which will run when this command is started.
  final void Function()? onStart;

  /// The function which will run when this command is stopped.
  final void Function()? onStop;

  /// The function which will undo the [onStart] function.
  final void Function()? onUndo;
}
