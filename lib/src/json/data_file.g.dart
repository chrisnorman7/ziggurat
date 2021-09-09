// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataFileEntry _$DataFileEntryFromJson(Map<String, dynamic> json) =>
    DataFileEntry(
      json['variableName'] as String,
      json['fileName'] as String,
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$DataFileEntryToJson(DataFileEntry instance) =>
    <String, dynamic>{
      'variableName': instance.variableName,
      'fileName': instance.fileName,
      'comment': instance.comment,
    };

DataFile _$DataFileFromJson(Map<String, dynamic> json) => DataFile(
      comment: json['comment'] as String?,
      entries: (json['entries'] as List<dynamic>?)
          ?.map((e) => DataFileEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DataFileToJson(DataFile instance) => <String, dynamic>{
      'entries': instance.entries,
      'comment': instance.comment,
    };
