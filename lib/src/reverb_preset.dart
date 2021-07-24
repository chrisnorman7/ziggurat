/// Provides the [ReverbPreset] class.
import 'package:dart_synthizer/dart_synthizer.dart';

import 'tile_types/surface.dart';

/// The bounds of a reverb property.
class ReverbPropertyBounds {
  /// Create an instance.
  const ReverbPropertyBounds(this.defaultValue, this.min, this.max);

  /// The default value.
  final double defaultValue;

  /// The minimum value.
  final double min;

  /// The maximum value.
  final double max;
}

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
  @ReverbPropertyBounds(0.1, 0.0, 0.5)
  final double meanFreePath;

  /// The T60 of the reverb.
  @ReverbPropertyBounds(0.3, 0.0, 100.0)
  final double t60;

  /// A multiplicative factor on T60 for the low frequency band.
  @ReverbPropertyBounds(1.0, 0.0, 2.0)
  final double lateReflectionsLfRolloff;

  /// Where the low band of the feedback equalizer ends.
  @ReverbPropertyBounds(200.0, 0.0, 22050.0)
  final double lateReflectionsLfReference;

  /// A multiplicative factor on T60 for the high frequency band.
  @ReverbPropertyBounds(0.5, 0.0, 2.0)
  final double lateReflectionsHfRolloff;

  /// Where the high band of the equalizer starts.
  @ReverbPropertyBounds(500.0, 0.0, 22050.0)
  final double lateReflectionsHfReference;

  /// Controls the diffusion of the late reflections as a percent.
  @ReverbPropertyBounds(1.0, 0.0, 1.0)
  final double lateReflectionsDiffusion;

  /// The depth of the modulation of the delay lines on the feedback path in
  /// seconds.
  @ReverbPropertyBounds(0.01, 0.0, 0.3)
  final double lateReflectionsModulationDepth;

  /// The frequency of the modulation of the delay lines in the feedback paths.
  @ReverbPropertyBounds(0.5, 0.01, 100.0)
  final double lateReflectionsModulationFrequency;

  /// The delay of the late reflections relative to the input in seconds.
  @ReverbPropertyBounds(0.03, 0.0, 0.5)
  final double lateReflectionsDelay;

  /// The gain of the reverb.
  @ReverbPropertyBounds(1.0, 0.01, 1.0)
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
