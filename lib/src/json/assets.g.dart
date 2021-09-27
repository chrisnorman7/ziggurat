// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets.dart';

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

AssetReferenceReference _$AssetReferenceReferenceFromJson(
        Map<String, dynamic> json) =>
    AssetReferenceReference(
      variableName: json['variableName'] as String,
      reference:
          AssetReference.fromJson(json['reference'] as Map<String, dynamic>),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$AssetReferenceReferenceToJson(
        AssetReferenceReference instance) =>
    <String, dynamic>{
      'variableName': instance.variableName,
      'comment': instance.comment,
      'reference': instance.reference,
    };

AssetStore _$AssetStoreFromJson(Map<String, dynamic> json) => AssetStore(
      json['filename'] as String,
      comment: json['comment'] as String?,
      assets: (json['assets'] as List<dynamic>?)
          ?.map((e) =>
              AssetReferenceReference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AssetStoreToJson(AssetStore instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'comment': instance.comment,
      'assets': instance.assets,
    };
