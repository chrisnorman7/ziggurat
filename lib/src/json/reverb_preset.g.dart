// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reverb_preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReverbPreset _$ReverbPresetFromJson(Map<String, dynamic> json) => ReverbPreset(
      json['name'] as String,
      meanFreePath: (json['meanFreePath'] as num?)?.toDouble() ?? 0.1,
      t60: (json['t60'] as num?)?.toDouble() ?? 0.3,
      lateReflectionsLfRolloff:
          (json['lateReflectionsLfRolloff'] as num?)?.toDouble() ?? 1.0,
      lateReflectionsLfReference:
          (json['lateReflectionsLfReference'] as num?)?.toDouble() ?? 200.0,
      lateReflectionsHfRolloff:
          (json['lateReflectionsHfRolloff'] as num?)?.toDouble() ?? 0.5,
      lateReflectionsHfReference:
          (json['lateReflectionsHfReference'] as num?)?.toDouble() ?? 500.0,
      lateReflectionsDiffusion:
          (json['lateReflectionsDiffusion'] as num?)?.toDouble() ?? 1.0,
      lateReflectionsModulationDepth:
          (json['lateReflectionsModulationDepth'] as num?)?.toDouble() ?? 0.01,
      lateReflectionsModulationFrequency:
          (json['lateReflectionsModulationFrequency'] as num?)?.toDouble() ??
              0.5,
      lateReflectionsDelay:
          (json['lateReflectionsDelay'] as num?)?.toDouble() ?? 0.03,
      gain: (json['gain'] as num?)?.toDouble() ?? 0.5,
    );

Map<String, dynamic> _$ReverbPresetToJson(ReverbPreset instance) =>
    <String, dynamic>{
      'name': instance.name,
      'meanFreePath': instance.meanFreePath,
      't60': instance.t60,
      'lateReflectionsLfRolloff': instance.lateReflectionsLfRolloff,
      'lateReflectionsLfReference': instance.lateReflectionsLfReference,
      'lateReflectionsHfRolloff': instance.lateReflectionsHfRolloff,
      'lateReflectionsHfReference': instance.lateReflectionsHfReference,
      'lateReflectionsDiffusion': instance.lateReflectionsDiffusion,
      'lateReflectionsModulationDepth': instance.lateReflectionsModulationDepth,
      'lateReflectionsModulationFrequency':
          instance.lateReflectionsModulationFrequency,
      'lateReflectionsDelay': instance.lateReflectionsDelay,
      'gain': instance.gain,
    };
