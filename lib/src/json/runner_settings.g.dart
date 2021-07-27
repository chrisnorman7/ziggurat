// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runner_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RunnerSettings _$RunnerSettingsFromJson(Map<String, dynamic> json) =>
    RunnerSettings(
      radarType: _$enumDecodeNullable(_$RadarTypeEnumMap, json['radarType']) ??
          RadarType.echoWalls,
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
    );

Map<String, dynamic> _$RunnerSettingsToJson(RunnerSettings instance) =>
    <String, dynamic>{
      'radarType': _$RadarTypeEnumMap[instance.radarType],
      'maxWallFilter': instance.maxWallFilter,
      'wallEchoMaxDistance': instance.wallEchoMaxDistance,
      'wallEchoMinDelay': instance.wallEchoMinDelay,
      'wallEchoDistanceOffset': instance.wallEchoDistanceOffset,
      'wallEchoGain': instance.wallEchoGain,
      'wallEchoGainRolloff': instance.wallEchoGainRolloff,
      'wallEchoFilterFrequency': instance.wallEchoFilterFrequency,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$RadarTypeEnumMap = {
  RadarType.disabled: 'disabled',
  RadarType.echoWalls: 'echoWalls',
  RadarType.echoOpenSpaces: 'echoOpenSpaces',
};
