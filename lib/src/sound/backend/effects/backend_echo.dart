/// Provides the [BackendEcho] class.
import '../sound_channel.dart';

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

/// Echo for a [SoundChannel] instance.
abstract class BackendEcho {
  /// Update the taps for this echo.
  void setTaps(final Iterable<EchoTap> taps);

  /// Reset this echo.
  void reset();

  /// Destroy this echo.
  void destroy();
}
