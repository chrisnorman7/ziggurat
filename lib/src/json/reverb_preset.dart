/// Provides the [ReverbPreset] class.
import 'package:json_annotation/json_annotation.dart';

import '../setting_defaults.dart';

part 'reverb_preset.g.dart';

/// A reverb preset.
@JsonSerializable()
class ReverbPreset {
  /// Create a preset.
  const ReverbPreset({
    required this.name,
    this.meanFreePath = 0.1,
    this.t60 = 0.3,
    this.lateReflectionsLfRolloff = 1.0,
    this.lateReflectionsLfReference = 200.0,
    this.lateReflectionsHfRolloff = 0.5,
    this.lateReflectionsHfReference = 500.0,
    this.lateReflectionsDiffusion = 1.0,
    this.lateReflectionsModulationDepth = 0.01,
    this.lateReflectionsModulationFrequency = 0.5,
    this.lateReflectionsDelay = 0.03,
    this.gain = 0.5,
  });

  /// Load an instance from json.
  factory ReverbPreset.fromJson(final Map<String, dynamic> json) =>
      _$ReverbPresetFromJson(json);

  /// The name of this preset.
  final String name;

  /// The mean free path of the simulated environment.
  @SettingDefaults(
    defaultValue: 0.1,
    min: 0.0,
    max: 0.5,
  )
  final double meanFreePath;

  /// The T60 of the reverb.
  @SettingDefaults(
    defaultValue: 0.3,
    min: 0.0,
    max: 100.0,
  )
  final double t60;

  /// A multiplicative factor on T60 for the low frequency band.
  @SettingDefaults(
    defaultValue: 1.0,
    min: 0.0,
    max: 2.0,
  )
  final double lateReflectionsLfRolloff;

  /// Where the low band of the feedback equalizer ends.
  @SettingDefaults(
    defaultValue: 200.0,
    min: 0.0,
    max: 22050.0,
  )
  final double lateReflectionsLfReference;

  /// A multiplicative factor on T60 for the high frequency band.
  @SettingDefaults(
    defaultValue: 0.5,
    min: 0.0,
    max: 2.0,
  )
  final double lateReflectionsHfRolloff;

  /// Where the high band of the equalizer starts.
  @SettingDefaults(
    defaultValue: 500.0,
    min: 0.0,
    max: 22050.0,
  )
  final double lateReflectionsHfReference;

  /// Controls the diffusion of the late reflections as a percent.
  @SettingDefaults(
    defaultValue: 1.0,
    min: 0.0,
    max: 1.0,
  )
  final double lateReflectionsDiffusion;

  /// The depth of the modulation of the delay lines on the feedback path in
  /// seconds.
  @SettingDefaults(
    defaultValue: 0.01,
    min: 0.0,
    max: 0.3,
  )
  final double lateReflectionsModulationDepth;

  /// The frequency of the modulation of the delay lines in the feedback paths.
  @SettingDefaults(
    defaultValue: 0.5,
    min: 0.01,
    max: 100.0,
  )
  final double lateReflectionsModulationFrequency;

  /// The delay of the late reflections relative to the input in seconds.
  @SettingDefaults(
    defaultValue: 0.03,
    min: 0.0,
    max: 0.5,
  )
  final double lateReflectionsDelay;

  /// The gain of the reverb.
  @SettingDefaults(
    defaultValue: 1.0,
    min: 0.01,
    max: 1.0,
  )
  final double gain;

  /// Dump this instance to JSON.
  Map<String, dynamic> toJson() => _$ReverbPresetToJson(this);
}
