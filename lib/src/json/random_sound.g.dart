// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'random_sound.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RandomSound _$RandomSoundFromJson(Map<String, dynamic> json) => RandomSound(
      sound: AssetReference.fromJson(json['sound'] as Map<String, dynamic>),
      minCoordinates: stringToPointDouble(json['minCoordinates']),
      maxCoordinates: stringToPointDouble(json['maxCoordinates']),
      minInterval: json['minInterval'] as int,
      maxInterval: json['maxInterval'] as int,
      minGain: (json['minGain'] as num?)?.toDouble() ?? 0.75,
      maxGain: (json['maxGain'] as num?)?.toDouble() ?? 0.75,
    );

Map<String, dynamic> _$RandomSoundToJson(RandomSound instance) =>
    <String, dynamic>{
      'sound': instance.sound,
      'minCoordinates': pointDoubleToString(instance.minCoordinates),
      'maxCoordinates': pointDoubleToString(instance.maxCoordinates),
      'minInterval': instance.minInterval,
      'maxInterval': instance.maxInterval,
      'minGain': instance.minGain,
      'maxGain': instance.maxGain,
    };
