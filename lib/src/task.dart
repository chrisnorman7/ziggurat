/// Provides the [Task] class.

/// A task which runs once on or after [runWhen].
class Task {
  /// Create a task.
  Task(this.runWhen, this.func);

  /// When should this task run.
  final int runWhen;

  /// The function which this task will run.
  final void Function() func;
}
