// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambiance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ambiance _$AmbianceFromJson(Map<String, dynamic> json) => Ambiance(
      sound: AssetReference.fromJson(json['sound'] as Map<String, dynamic>),
      position: stringToPointDoubleNullable(json['position']),
    );

Map<String, dynamic> _$AmbianceToJson(Ambiance instance) => <String, dynamic>{
      'sound': instance.sound,
      'position': pointDoubleToString(instance.position),
    };
