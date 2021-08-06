// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VaultFile _$VaultFileFromJson(Map<String, dynamic> json) => VaultFile(
      files: (json['files'] as Map<String, dynamic>?)?.map(
        (k, dynamic e) => MapEntry(k, e as String),
      ),
      folders: (json['folders'] as Map<String, dynamic>?)?.map(
        (k, dynamic e) => MapEntry(
            k, (e as List<dynamic>).map((dynamic e) => e as String).toList()),
      ),
    );

Map<String, dynamic> _$VaultFileToJson(VaultFile instance) => <String, dynamic>{
      'files': instance.files,
      'folders': instance.folders,
    };
