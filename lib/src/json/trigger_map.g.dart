// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger_map.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TriggerMap _$TriggerMapFromJson(Map<String, dynamic> json) => TriggerMap(
      (json['triggers'] as List<dynamic>)
          .map((e) => CommandTrigger.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TriggerMapToJson(TriggerMap instance) =>
    <String, dynamic>{
      'triggers': instance.triggers,
    };
