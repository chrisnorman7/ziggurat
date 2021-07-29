// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runner_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RunnerSettings _$RunnerSettingsFromJson(Map<String, dynamic> json) =>
    RunnerSettings(
      wallEchoEnabled: json['wallEchoEnabled'] as bool? ?? true,
      maxWallFilter: (json['maxWallFilter'] as num?)?.toDouble() ?? 500.0,
      wallEchoMaxDistance: json['wallEchoMaxDistance'] as int? ?? 5,
      wallEchoMinDelay: (json['wallEchoMinDelay'] as num?)?.toDouble() ?? 0.05,
      wallEchoDistanceOffset:
          (json['wallEchoDistanceOffset'] as num?)?.toDouble() ?? 0.01,
      wallEchoGain: (json['wallEchoGain'] as num?)?.toDouble() ?? 0.5,
      wallEchoGainRolloff:
          (json['wallEchoGainRolloff'] as num?)?.toDouble() ?? 0.2,
      wallEchoFilterFrequency:
          (json['wallEchoFilterFrequency'] as num?)?.toDouble() ?? 12000,
      directionalRadarEnabled: json['directionalRadarEnabled'] as bool? ?? true,
      directionalRadarGain:
          (json['directionalRadarGain'] as num?)?.toDouble() ?? 0.7,
      directionalRadarDistance:
          (json['directionalRadarDistance'] as num?)?.toDouble() ?? 10,
      directionalRadarEmptySpaceSound:
          pathFromValue(json['directionalRadarEmptySpaceSound']),
      directionalRadarDoorSound:
          pathFromValue(json['directionalRadarDoorSound']),
      directionalRadarWallSound:
          pathFromValue(json['directionalRadarWallSound']),
      directionalRadarDirections:
          (json['directionalRadarDirections'] as List<dynamic>?)
                  ?.map((dynamic e) => e as int)
                  .toList() ??
              const [0, 90, 270],
    );

Map<String, dynamic> _$RunnerSettingsToJson(RunnerSettings instance) =>
    <String, dynamic>{
      'wallEchoEnabled': instance.wallEchoEnabled,
      'maxWallFilter': instance.maxWallFilter,
      'wallEchoMaxDistance': instance.wallEchoMaxDistance,
      'wallEchoMinDelay': instance.wallEchoMinDelay,
      'wallEchoDistanceOffset': instance.wallEchoDistanceOffset,
      'wallEchoGain': instance.wallEchoGain,
      'wallEchoGainRolloff': instance.wallEchoGainRolloff,
      'wallEchoFilterFrequency': instance.wallEchoFilterFrequency,
      'directionalRadarEnabled': instance.directionalRadarEnabled,
      'directionalRadarGain': instance.directionalRadarGain,
      'directionalRadarDistance': instance.directionalRadarDistance,
      'directionalRadarEmptySpaceSound':
          pathToValue(instance.directionalRadarEmptySpaceSound),
      'directionalRadarDoorSound':
          pathToValue(instance.directionalRadarDoorSound),
      'directionalRadarWallSound':
          pathToValue(instance.directionalRadarWallSound),
      'directionalRadarDirections': instance.directionalRadarDirections,
    };
