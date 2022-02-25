/// Provides the [Task] class.
import '../../levels.dart';

/// The signature for task functions.
typedef TaskFunction = void Function();

/// A task which runs once on or after [runAfter].
class Task {
  /// Create a task.
  const Task({
    required this.func,
    required this.runAfter,
    this.interval,
    this.level,
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

  /// The level this task is bound to.
  ///
  /// If [level] is `null`, the task will run and be scheduled regardless of
  /// what level is currently on top of the levels stack. Otherwise, the game
  /// will skip over this task if the top-most level is not [level].
  final Level? level;
}
