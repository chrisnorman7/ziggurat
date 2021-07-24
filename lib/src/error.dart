/// Provides various error types.
import 'runner.dart';
import 'ziggurat.dart';

/// The base class for all ziggurat errors.
class ZigguratError extends Error {}

/// The error which is thrown when a [Runner] has no [Ziggurat] loaded.
class NoZigguratError extends ZigguratError {
  /// Create the exception.
  NoZigguratError(this.runner);

  /// The runner which was at fault.
  final Runner runner;

  /// Change the string representation of this object.
  @override
  String toString() => 'No ziggurat on $runner.';
}
