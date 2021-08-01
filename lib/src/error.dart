/// Provides various error types.
import 'dart:io';

import 'box.dart';
import 'box_types/agents/player.dart';
import 'event_loop.dart';
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

/// The start coordinates of [box] contains a negative number.
class NegativeCoordinatesError extends ZigguratError {
  /// Create the error.
  NegativeCoordinatesError(this.box);

  /// The box with the invalid coordinates.
  final Box box;

  /// Return a string.
  @override
  String toString() =>
      'Negative coordinates for box ${box.name}: ${box.start}.';
}

/// A player has been included in the list of tiles given to [ziggurat].
class PlayerInBoxesError extends ZigguratError {
  /// Create the error.
  PlayerInBoxesError(this.player, this.ziggurat);

  /// The player that was found.
  final Box<Player> player;

  /// The ziggurat that [player] was included in.
  final Ziggurat ziggurat;
}

/// An [EventLoop] instance is in an invalid state.
class InvalidStateError extends ZigguratError {
  /// Create an error.
  InvalidStateError(this.eventLoop);

  /// The loop which is already running.
  final EventLoop eventLoop;
}
