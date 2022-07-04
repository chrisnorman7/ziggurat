/// Provides the [SilentBackendReverb] class.
import '../../../../json/reverb_preset.dart';
import '../../effects/backend_reverb.dart';

/// A silent reverb.
///
/// This class does nothing.
class SilentBackendReverb implements BackendReverb {
  /// Create an instance.
  const SilentBackendReverb();

  @override
  void clearFilter() {}

  @override
  void destroy() {}

  @override
  void filterBandpass(final double frequency, final double bandwidth) {}

  @override
  void filterHighpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  }) {}

  @override
  void filterLowpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  }) {}

  @override
  void reset() {}

  @override
  void setPreset(final ReverbPreset preset, {final double? fadeTime}) {}
}
