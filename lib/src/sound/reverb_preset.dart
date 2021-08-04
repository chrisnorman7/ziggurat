/// Provides the [ReverbPreset] class.
import 'package:dart_synthizer/dart_synthizer.dart';

import '../box_types/surface.dart';
import '../setting_defaults.dart';

/// A reverb preset.
///
/// You can create as many presets as you need, and add them to [Surface]
/// instances.
class ReverbPreset {
  /// Create a preset.
  ReverbPreset(this.name,
      {this.meanFreePath = 0.1,
      this.t60 = 0.3,
      this.lateReflectionsLfRolloff = 1.0,
      this.lateReflectionsLfReference = 200.0,
      this.lateReflectionsHfRolloff = 0.5,
      this.lateReflectionsHfReference = 500.0,
      this.lateReflectionsDiffusion = 1.0,
      this.lateReflectionsModulationDepth = 0.01,
      this.lateReflectionsModulationFrequency = 0.5,
      this.lateReflectionsDelay = 0.03,
      this.gain = 0.5});

  /// The name of this preset.
  final String name;

  /// The mean free path of the simulated environment.
  @SettingDefaults(0.1, 0.0, 0.5)
  final double meanFreePath;

  /// The T60 of the reverb.
  @SettingDefaults(0.3, 0.0, 100.0)
  final double t60;

  /// A multiplicative factor on T60 for the low frequency band.
  @SettingDefaults(1.0, 0.0, 2.0)
  final double lateReflectionsLfRolloff;

  /// Where the low band of the feedback equalizer ends.
  @SettingDefaults(200.0, 0.0, 22050.0)
  final double lateReflectionsLfReference;

  /// A multiplicative factor on T60 for the high frequency band.
  @SettingDefaults(0.5, 0.0, 2.0)
  final double lateReflectionsHfRolloff;

  /// Where the high band of the equalizer starts.
  @SettingDefaults(500.0, 0.0, 22050.0)
  final double lateReflectionsHfReference;

  /// Controls the diffusion of the late reflections as a percent.
  @SettingDefaults(1.0, 0.0, 1.0)
  final double lateReflectionsDiffusion;

  /// The depth of the modulation of the delay lines on the feedback path in
  /// seconds.
  @SettingDefaults(0.01, 0.0, 0.3)
  final double lateReflectionsModulationDepth;

  /// The frequency of the modulation of the delay lines in the feedback paths.
  @SettingDefaults(0.5, 0.01, 100.0)
  final double lateReflectionsModulationFrequency;

  /// The delay of the late reflections relative to the input in seconds.
  @SettingDefaults(0.03, 0.0, 0.5)
  final double lateReflectionsDelay;

  /// The gain of the reverb.
  @SettingDefaults(1.0, 0.01, 1.0)
  final double gain;

  /// Make a reverb object from this preset.
  GlobalFdnReverb makeReverb(Context context) {
    final r = GlobalFdnReverb(context)
      ..meanFreePath = meanFreePath
      ..t60 = t60
      ..lateReflectionsLfRolloff = lateReflectionsLfRolloff
      ..lateReflectionsLfReference = lateReflectionsLfReference
      ..lateReflectionsHfRolloff = lateReflectionsHfRolloff
      ..lateReflectionsHfReference = lateReflectionsHfReference
      ..lateReflectionsDiffusion = lateReflectionsDiffusion
      ..lateReflectionsModulationDepth = lateReflectionsModulationDepth
      ..lateReflectionsModulationFrequency = lateReflectionsModulationFrequency
      ..lateReflectionsDelay = lateReflectionsDelay
      ..gain = gain;
    return r;
  }
}
