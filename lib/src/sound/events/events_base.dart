/// Provides sound events and the [SoundEvent] class.
export 'automation_fade.dart';
export 'playback.dart';
export 'reverb.dart';
export 'sound_channel.dart';
export 'sound_position.dart';

/// The base class for all sound events.
class SoundEvent {
  /// Create an event.
  const SoundEvent({this.id});

  /// The ID of this event.
  final int? id;

  /// This value is incremented and used by those events which require an ID.
  static int maxEventId = 0;

  /// Get the next valid ID.
  static int nextId() => ++maxEventId;
}
