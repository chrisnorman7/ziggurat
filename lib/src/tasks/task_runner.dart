/// Provides the [TaskRunner] class.
import '../game.dart';
import 'task.dart';

/// A class for holding information about a running [task].
class TaskRunner {
  /// Create an instance.
  TaskRunner(this.task)
      : timeWaited = 0,
        numberOfRuns = 0;

  /// The task that is to be run.
  final Task task;

  /// The time since this runner was created, or since the [task] was last ran.
  ///
  /// This value will be incremented by [Game.tick].
  int timeWaited;

  /// The number of times that [task] has run so far.
  int numberOfRuns;

  /// Run [task], and update [numberOfRuns] and [timeWaited].
  void run() {
    task.func();
    numberOfRuns++;
    timeWaited = 0;
  }
}
