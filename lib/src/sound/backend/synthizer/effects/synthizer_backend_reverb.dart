import 'package:dart_synthizer/dart_synthizer.dart';

import '../../../../../sound.dart';
import '../../effects/backend_reverb.dart';
import '../synthizer_sound_backend.dart';

/// A class for changing reverb settings.
class _ChangeReverbSetting {
  /// Create an instance.
  const _ChangeReverbSetting({
    required this.property,
    required this.value,
  });

  /// The property to modify.
  final SynthizerAutomatableDoubleProperty property;

  /// The new value.
  final double value;
}

/// A synthizer reverb.
class SynthizerBackendReverb implements BackendReverb {
  /// Create an instance.
  const SynthizerBackendReverb({
    required this.backend,
    required this.reverb,
  });

  /// The backend to work with.
  final SynthizerSoundBackend backend;

  /// The reverb instance to work with.
  final GlobalFdnReverb reverb;

  /// The synthizer instance to use.
  Synthizer get synthizer => backend.context.synthizer;

  /// Destroy [reverb].
  @override
  void destroy() {
    reverb.destroy();
  }

  @override
  void setPreset(
    final ReverbPreset preset, {
    final double? fadeTime,
  }) {
    final startTime = backend.context.currentTime.value;
    final endTime = startTime + (fadeTime ?? 0.1);
    for (final changeSetting in [
      _ChangeReverbSetting(property: reverb.gain, value: preset.gain),
      _ChangeReverbSetting(
        property: reverb.lateReflectionsDelay,
        value: preset.lateReflectionsDelay,
      ),
      _ChangeReverbSetting(
        property: reverb.lateReflectionsDiffusion,
        value: preset.lateReflectionsDiffusion,
      ),
      _ChangeReverbSetting(
        property: reverb.lateReflectionsHfReference,
        value: preset.lateReflectionsHfReference,
      ),
      _ChangeReverbSetting(
        property: reverb.lateReflectionsHfRolloff,
        value: preset.lateReflectionsHfRolloff,
      ),
      _ChangeReverbSetting(
        property: reverb.lateReflectionsLfReference,
        value: preset.lateReflectionsLfReference,
      ),
      _ChangeReverbSetting(
        property: reverb.lateReflectionsLfRolloff,
        value: preset.lateReflectionsLfRolloff,
      ),
      _ChangeReverbSetting(
        property: reverb.lateReflectionsModulationDepth,
        value: preset.lateReflectionsModulationDepth,
      ),
      _ChangeReverbSetting(
        property: reverb.lateReflectionsModulationFrequency,
        value: preset.lateReflectionsModulationFrequency,
      ),
      _ChangeReverbSetting(
        property: reverb.meanFreePath,
        value: preset.meanFreePath,
      ),
      _ChangeReverbSetting(property: reverb.t60, value: preset.t60),
    ]) {
      final property = changeSetting.property;
      if (fadeTime == null) {
        property.value = changeSetting.value;
      } else {
        changeSetting.property.automate(
          startTime: startTime,
          startValue: property.value,
          endTime: endTime,
          endValue: changeSetting.value,
        );
      }
    }
  }

  /// Clear filtering.
  @override
  void clearFilter() {
    reverb.filterInput.value = BiquadConfig.designIdentity(synthizer);
  }

  /// Add a bandpass.
  @override
  void filterBandpass(final double frequency, final double bandwidth) {
    reverb.filterInput.value = BiquadConfig.designBandpass(
      synthizer,
      frequency,
      bandwidth,
    );
  }

  /// Add a highpass.
  @override
  void filterHighpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  }) {
    reverb.filterInput.value = BiquadConfig.designHighpass(
      synthizer,
      frequency,
      q: q,
    );
  }

  /// Add a low pass.
  @override
  void filterLowpass(
    final double frequency, {
    final double q = 0.7071135624381276,
  }) {
    reverb.filterInput.value = BiquadConfig.designLowpass(
      synthizer,
      frequency,
      q: q,
    );
  }

  @override
  void reset() {
    reverb.reset();
  }
}
