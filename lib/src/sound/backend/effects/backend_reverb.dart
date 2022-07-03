/// Provides the [BackendReverb] class.
import '../../../json/reverb_preset.dart';

/// A reverb bus.
abstract class BackendReverb {
  /// Destroy this reverb.
  void destroy();

  /// Update the preset for this reverb.
  void setPreset(final ReverbPreset preset, {final double? fadeTime});

  /// Remove any filtering applied to this reverb.
  void clearFilter();

  /// Apply a lowpass to this reverb.
  void filterLowpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  });

  /// Apply a highpass to this reverb.
  void filterHighpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  });

  /// Add a bandpass to this reverb.
  void filterBandpass(final double frequency, final double bandwidth);

  /// Reset this reverb.
  void reset();
}
