// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Music _$MusicFromJson(Map<String, dynamic> json) => Music(
      AssetReference.fromJson(json['sound'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MusicToJson(Music instance) => <String, dynamic>{
      'sound': instance.sound,
    };
