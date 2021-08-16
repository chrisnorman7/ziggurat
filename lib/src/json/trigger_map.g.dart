// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger_map.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TriggerMap _$TriggerMapFromJson(Map<String, dynamic> json) => TriggerMap(
      (json['triggers'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, CommandTrigger.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$TriggerMapToJson(TriggerMap instance) =>
    <String, dynamic>{
      'triggers': instance.triggers,
    };
