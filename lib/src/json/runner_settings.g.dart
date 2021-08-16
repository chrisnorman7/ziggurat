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
          json['directionalRadarEmptySpaceSound'] == null
              ? null
              : SoundReference.fromJson(json['directionalRadarEmptySpaceSound']
                  as Map<String, dynamic>),
      directionalRadarDoorSound: json['directionalRadarDoorSound'] == null
          ? null
          : SoundReference.fromJson(
              json['directionalRadarDoorSound'] as Map<String, dynamic>),
      directionalRadarWallSound: json['directionalRadarWallSound'] == null
          ? null
          : SoundReference.fromJson(
              json['directionalRadarWallSound'] as Map<String, dynamic>),
      directionalRadarDirections:
          (json['directionalRadarDirections'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toList() ??
              const [0, 90, 270],
      directionalRadarResetOnTurn:
          json['directionalRadarResetOnTurn'] as bool? ?? true,
      directionalRadarAlertOnChange:
          json['directionalRadarAlertOnChange'] as bool? ?? true,
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
          instance.directionalRadarEmptySpaceSound,
      'directionalRadarDoorSound': instance.directionalRadarDoorSound,
      'directionalRadarWallSound': instance.directionalRadarWallSound,
      'directionalRadarDirections': instance.directionalRadarDirections,
      'directionalRadarResetOnTurn': instance.directionalRadarResetOnTurn,
      'directionalRadarAlertOnChange': instance.directionalRadarAlertOnChange,
    };
