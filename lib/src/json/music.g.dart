// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Music _$MusicFromJson(Map<String, dynamic> json) => Music(
      sound: AssetReference.fromJson(json['sound'] as Map<String, dynamic>),
      gain: (json['gain'] as num).toDouble(),
    );

Map<String, dynamic> _$MusicToJson(Music instance) => <String, dynamic>{
      'sound': instance.sound,
      'gain': instance.gain,
    };
