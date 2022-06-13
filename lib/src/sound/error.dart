/// The base class for all errors in this package.
class ZigguratSoundsError implements Exception {}

/// No such channel was found.
class NoSuchChannelError extends ZigguratSoundsError {
  /// Create an instance.
  NoSuchChannelError(this.id);

  /// The ID of the channel.
  final int id;

  @override
  String toString() => 'No such channel: $id.';
}

/// No such reverb was found.
class NoSuchReverbError extends ZigguratSoundsError {
  /// Create an instance.
  NoSuchReverbError(this.id);

  /// The ID of the reverb.
  final int id;

  @override
  String toString() => 'No such reverb: $id.';
}

/// No such sound was found.
class NoSuchSoundError extends ZigguratSoundsError {
  /// Create an instance.
  NoSuchSoundError(this.id);

  /// The ID of the sound.
  final int id;

  @override
  String toString() => 'No sound found with ID $id.';
}

/// No such wave was found.
class NoSuchWaveError extends ZigguratSoundsError {
  /// Create an instance.
  NoSuchWaveError(this.id);

  /// The ID of the wave.
  final int id;

  @override
  String toString() => 'No wave found with ID $id.';
}
