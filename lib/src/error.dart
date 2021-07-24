/// Provides various error types.
import 'dart:io';

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

/// An attempt was made to get a random file from an empty directory.
class NoFilesError extends ZigguratError {
  /// Create the error.
  NoFilesError(this.directory);

  /// The directory which was accessed.
  final Directory directory;

  /// Return a string explaining this error.
  @override
  String toString() => 'No files were found in $directory.';
}

/// While looking for a random file, something that was neither a directory or
/// a file was encountered.
class InvalidEntityError extends ZigguratError {
  /// Create the instance.
  InvalidEntityError(this.entity);

  /// The entity in question.
  final FileSystemEntity entity;

  /// Explain the error.
  @override
  String toString() => 'Unknown entity $entity (${entity.runtimeType}).';
}
