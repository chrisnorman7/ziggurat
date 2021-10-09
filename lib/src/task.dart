/// Provides the [Task] class.
import 'game.dart';

/// The signature for task functions.
typedef TaskFunction = void Function();

/// A task which runs once on or after [runWhen].
class Task {
  /// Create a task.
  Task(this.runWhen, this.interval, this.func);

  /// When should this task run.
  int runWhen;

  /// How regularly this task should run.
  ///
  /// Although this value can be changed, if the task runs with a `null`
  /// interval, it will be removed from the game's [Game.tasks] list.
  int? interval;

  /// The function which this task will run.
  final TaskFunction func;
}
