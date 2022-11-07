// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rumble_effect.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RumbleEffect _$RumbleEffectFromJson(Map<String, dynamic> json) => RumbleEffect(
      duration: json['duration'] as int,
      lowFrequency: json['lowFrequency'] as int? ?? 65535,
      highFrequency: json['highFrequency'] as int? ?? 65535,
    );

Map<String, dynamic> _$RumbleEffectToJson(RumbleEffect instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'lowFrequency': instance.lowFrequency,
      'highFrequency': instance.highFrequency,
    };
