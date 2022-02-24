/// The signature for task functions.
typedef TaskFunction = void Function();

/// A task which runs once on or after [runAfter].
class Task {
  /// Create a task.
  const Task({
    required this.func,
    required this.runAfter,
    this.interval,
  });

  /// How many milliseconds should elapse before [func] is called.
  final int runAfter;

  /// How regularly this task should run.
  ///
  /// If this value is not `null`, [runAfter] will elapse before [func] is
  /// called for the first time. After that, [interval] will be waited before
  /// subsequent runs.
  final int? interval;

  /// The function which this task will run.
  final TaskFunction func;
}
