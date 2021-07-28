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
      leftRightRadarEnabled: json['leftRightRadarEnabled'] as bool? ?? true,
      leftRightRadarGain:
          (json['leftRightRadarGain'] as num?)?.toDouble() ?? 0.7,
      leftRightRadarDistance:
          (json['leftRightRadarDistance'] as num?)?.toDouble() ?? 10,
      leftRightRadarEmptySpaceSound:
          pathFromValue(json['leftRightRadarEmptySpaceSound']),
      leftRightRadarDoorSound: pathFromValue(json['leftRightRadarDoorSound']),
      leftRightRadarWallSound: pathFromValue(json['leftRightRadarWallSound']),
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
      'leftRightRadarEnabled': instance.leftRightRadarEnabled,
      'leftRightRadarGain': instance.leftRightRadarGain,
      'leftRightRadarDistance': instance.leftRightRadarDistance,
      'leftRightRadarEmptySpaceSound':
          pathToValue(instance.leftRightRadarEmptySpaceSound),
      'leftRightRadarDoorSound': pathToValue(instance.leftRightRadarDoorSound),
      'leftRightRadarWallSound': pathToValue(instance.leftRightRadarWallSound),
    };
