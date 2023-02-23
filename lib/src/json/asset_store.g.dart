// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetStore _$AssetStoreFromJson(Map<String, dynamic> json) => AssetStore(
      filename: json['filename'] as String,
      destination: json['destination'] as String,
      assets: (json['assets'] as List<dynamic>)
          .map((e) =>
              AssetReferenceReference.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$AssetStoreToJson(AssetStore instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'destination': instance.destination,
      'comment': instance.comment,
      'assets': instance.assets,
    };
