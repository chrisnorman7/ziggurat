import '../next_run.dart';
import 'task.dart';

/// A class for holding information about a running [value].
class TaskRunner extends NextRun<Task> {
  /// Create an instance.
  TaskRunner(final Task value)
      : numberOfRuns = 0,
        super(value);

  /// The number of times that [value] has run so far.
  int numberOfRuns;

  /// Run [value], and update [numberOfRuns] and [runAfter].
  void run() {
    value.func();
    numberOfRuns++;
    runAfter = 0;
  }
}
