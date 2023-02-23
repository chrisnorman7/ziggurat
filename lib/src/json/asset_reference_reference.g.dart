// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_reference_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
