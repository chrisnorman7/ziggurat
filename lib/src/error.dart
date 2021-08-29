/// Provides various error types.
import 'dart:io';

import 'box_map/box.dart';
import 'box_map/box_types/agents/player.dart';
import 'game.dart';
import 'sound/events/events_base.dart';
import 'ziggurat.dart';

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

/// A player has been included in the list of tiles given to [ziggurat].
class PlayerInBoxesError extends ZigguratError {
  /// Create the error.
  PlayerInBoxesError(this.player, this.ziggurat);

  /// The player that was found.
  final Box<Player> player;

  /// The ziggurat that [player] was included in.
  final Ziggurat ziggurat;
}

/// A [Game] instance is in an invalid state.
class InvalidStateError extends ZigguratError {
  /// Create an error.
  InvalidStateError(this.game);

  /// The game which is already running.
  final Game game;
}

/// An invalid command name was used.
class InvalidCommandNameError extends ZigguratError {
  /// Create an error.
  InvalidCommandNameError(this.name);

  /// The invalid name.
  final String name;
  @override
  String toString() => 'Invalid command name: $name.';
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
