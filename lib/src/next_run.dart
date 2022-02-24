/// Provides the [NextRun] class.
import 'json/random_sound.dart';

/// A class that holds information about when its [value] should run next.
///
/// This class is necessary in order to have as many constant constructors as
/// possible, necessitating things that need to store state, like [RandomSound]
/// instances for example. Using this class, we can decouple the time something
/// next needs to happen to [value], from the implementation of [value] itself.
class NextRun<T> {
  /// Create an instance.
  NextRun(this.value, {this.runAfter = 0});

  /// The thing that should be run.
  final T value;

  /// How long until [value] should be run.
  int runAfter;
}
