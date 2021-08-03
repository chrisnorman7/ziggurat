// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VaultFile _$VaultFileFromJson(Map<String, dynamic> json) => VaultFile(
      files: (json['files'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as int).toList()),
      ),
      folders: (json['folders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => (e as List<dynamic>).map((e) => e as int).toList())
                .toList()),
      ),
    );

Map<String, dynamic> _$VaultFileToJson(VaultFile instance) => <String, dynamic>{
      'files': instance.files,
      'folders': instance.folders,
    };
