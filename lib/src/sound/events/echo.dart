/// Events relating to echo.
import '../../game.dart';
import 'events_base.dart';

/// A tap for an echo.
class EchoTap {
  /// Create an instance.
  const EchoTap({
    required this.delay,
    this.gainL = 0.7,
    this.gainR = 0.7,
  });

  /// The number of milliseconds before this delay is heard.
  final double delay;

  /// The gain of the left channel.
  final double gainL;

  /// The gain of the right channel.
  final double gainR;

  /// Describe this object.
  @override
  String toString() =>
      '<$runtimeType delay: $delay, gainL: $gainL, gainR: $gainR>';
}

/// Create an echo.
class CreateEcho extends SoundEvent {
  /// Create an instance.
  const CreateEcho({
    required final int id,
    required this.game,
    required final List<EchoTap> taps,
  })  : _taps = taps,
        super(id: id);

  /// The game to use.
  final Game game;

  final List<EchoTap> _taps;

  /// The taps to use.
  List<EchoTap> get taps => _taps;

  /// Set the [taps].
  set taps(final List<EchoTap> value) {
    taps
      ..clear()
      ..addAll(value);
    game.queueSoundEvent(ModifyEchoTaps(id: id!, taps: value));
  }

  /// Destroy this echo.
  void destroy() {
    game.queueSoundEvent(DestroyEcho(id!));
  }

  /// Reset this echo.
  void reset() => game.queueSoundEvent(ResetEcho(id!));

  /// Describe this object.
  @override
  String toString() => '<$runtimeType id: $id, taps: $_taps>';
}

/// Modify the taps for a [CreateEcho] instance.
class ModifyEchoTaps extends SoundEvent {
  /// Create an instance.
  const ModifyEchoTaps({
    required final int id,
    required this.taps,
  }) : super(id: id);

  /// The new taps to use.
  final List<EchoTap> taps;
}

/// Destroy a [CreateEcho] instance.
class DestroyEcho extends SoundEvent {
  /// Create an instance.
  const DestroyEcho(final int id) : super(id: id);
}

/// Reset the [CreateEcho] instance with the given [id].
class ResetEcho extends SoundEvent {
  /// Create an instance.
  const ResetEcho(final int id) : super(id: id);
}
