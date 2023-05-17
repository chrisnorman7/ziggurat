// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_stub.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LevelStub _$LevelStubFromJson(Map<String, dynamic> json) => LevelStub(
      music: json['music'] == null
          ? null
          : AssetReference.fromJson(json['music'] as Map<String, dynamic>),
      ambiances: (json['ambiances'] as List<dynamic>?)
              ?.map((e) => Ambiance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      randomSounds: (json['randomSounds'] as List<dynamic>?)
              ?.map((e) => RandomSound.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LevelStubToJson(LevelStub instance) => <String, dynamic>{
      'music': instance.music,
      'ambiances': instance.ambiances,
      'randomSounds': instance.randomSounds,
    };
