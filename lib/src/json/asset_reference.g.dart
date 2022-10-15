// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetReference _$AssetReferenceFromJson(Map<String, dynamic> json) =>
    AssetReference(
      json['name'] as String,
      $enumDecode(_$AssetTypeEnumMap, json['type']),
      encryptionKey: json['encryptionKey'] as String?,
      gain: (json['gain'] as num?)?.toDouble() ?? defaultGain,
    );

Map<String, dynamic> _$AssetReferenceToJson(AssetReference instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$AssetTypeEnumMap[instance.type]!,
      'encryptionKey': instance.encryptionKey,
      'gain': instance.gain,
    };

const _$AssetTypeEnumMap = {
  AssetType.file: 'file',
  AssetType.collection: 'collection',
};
