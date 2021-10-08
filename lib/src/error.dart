/// Provides various error types.
import 'dart:io';

import 'box_map/box.dart';
import 'sound/events/events_base.dart';

/// The base class for all ziggurat errors.
class ZigguratError extends Error {}

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

/// The [sound] had its [PlaySound.keepAlive] value set to `false`.
class DeadSound extends ZigguratError {
  /// Create an instance.
  DeadSound(this.sound);

  /// The sound that was supposed to be destroyed.
  final PlaySound sound;

  @override
  String toString() => 'Sound $sound was already scheduled for destruction.';
}

/// An attempt was made to set a channel position to a position not supported
/// by its source type.
class PositionMismatchError extends ZigguratError {
  /// Create an instance.
  PositionMismatchError(this.channel, this.position);

  /// The channel whose position was supposed to be set.
  final SoundChannel channel;

  /// The position that was used.
  final SoundPosition position;

  @override
  String toString() => 'Cannot set position of $channel to $position.';
}

/// An attempt was made to register a duplicate command name.
class DuplicateCommandName extends ZigguratError {
  /// Create the error.
  DuplicateCommandName(this.name);

  /// The name of the command.
  final String name;
}
