/// Provides the [SilentWave] class.
import '../wave.dart';

/// A silent wave.
///
/// This class does nothing.
class SilentWave implements Wave {
  /// Create an instance.
  SilentWave({
    required this.gain,
  });

  @override
  void cancelFade() {}

  @override
  void destroy() {}

  @override
  void fade({
    required final double length,
    final double endGain = 0.0,
    final double? startGain,
    final double preFade = 0.0,
  }) {}

  @override
  double gain;

  @override
  void pause() {}

  @override
  void setFrequency(final double frequency, {final double? time}) {}

  @override
  void unpause() {}
}
