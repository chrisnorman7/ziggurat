/// Provides events relating to reverb.
import '../../game.dart';
import '../reverb_preset.dart';
import 'events_base.dart';
import 'playback.dart';

/// Create a reverb.
class CreateReverb extends SoundEvent {
  /// Create a reverb.
  const CreateReverb(
      {required this.game, required int id, required this.reverb})
      : super(id: id);

  /// The game to use.
  final Game game;

  /// The reverb preset to use.
  final ReverbPreset reverb;

  /// Destroy this reverb.
  void destroy() => game.queueSoundEvent(DestroyReverb(id!));
}

/// Destroy a pre-existing reverb.
///
/// NOTE: No error checking is performed by [PlaySound]. If a reverb is
/// destroyed using this event, and then another sound attempts to play through
/// the same reverb, the behaviour is undefined.
class DestroyReverb extends SoundEvent {
  /// Create an event.
  const DestroyReverb(int id) : super(id: id);
}
