// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetReference _$AssetReferenceFromJson(Map<String, dynamic> json) =>
    AssetReference(
      json['name'] as String,
      _$enumDecode(_$AssetTypeEnumMap, json['type']),
      encryptionKey: json['encryptionKey'] as String?,
    );

Map<String, dynamic> _$AssetReferenceToJson(AssetReference instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$AssetTypeEnumMap[instance.type],
      'encryptionKey': instance.encryptionKey,
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

const _$AssetTypeEnumMap = {
  AssetType.file: 'file',
  AssetType.collection: 'collection',
};
