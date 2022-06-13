/// Provides various error types.
import 'dart:io';
import 'dart:math';

import 'sound/events/playback.dart';
import 'sound/events/sound_channel.dart';
import 'sound/events/sound_position.dart';

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

/// The base class for all sound errors.
class SoundsError extends ZigguratError {}

/// No such buffer was found.
class NoSuchBufferError extends SoundsError {
  /// Create an instance.
  NoSuchBufferError(this.file);

  /// The file which does not exist.
  final File file;
}

/// No such channel was found.
class NoSuchChannelError extends SoundsError {
  /// Create an instance.
  NoSuchChannelError(this.id);

  /// The ID of the channel.
  final int id;

  @override
  String toString() => 'No such channel: $id.';
}

/// No such reverb was found.
class NoSuchReverbError extends SoundsError {
  /// Create an instance.
  NoSuchReverbError(this.id);

  /// The ID of the reverb.
  final int id;

  @override
  String toString() => 'No such reverb: $id.';
}

/// No such sound was found.
class NoSuchSoundError extends SoundsError {
  /// Create an instance.
  NoSuchSoundError(this.id);

  /// The ID of the sound.
  final int id;

  @override
  String toString() => 'No sound found with ID $id.';
}

/// No such wave was found.
class NoSuchWaveError extends SoundsError {
  /// Create an instance.
  NoSuchWaveError(this.id);

  /// The ID of the wave.
  final int id;

  @override
  String toString() => 'No wave found with ID $id.';
}

/// The [sound] had its [PlaySound.keepAlive] value set to `false`.
class DeadSound extends SoundsError {
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

/// The player is not on a box.
class NoBoxError extends ZigguratError {
  /// Create an instance.
  NoBoxError(this.coordinates);

  /// The coordinates where no box was found.
  final Point<double> coordinates;
  @override
  String toString() => 'There is no box at $coordinates.';
}
