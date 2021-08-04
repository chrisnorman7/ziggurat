// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SoundReference _$SoundReferenceFromJson(Map<String, dynamic> json) =>
    SoundReference(
      json['name'] as String,
      _$enumDecode(_$SoundTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$SoundReferenceToJson(SoundReference instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$SoundTypeEnumMap[instance.type],
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

const _$SoundTypeEnumMap = {
  SoundType.file: 'file',
  SoundType.collection: 'collection',
};
