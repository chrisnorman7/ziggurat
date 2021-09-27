// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      text: json['text'] as String?,
      sound: json['sound'] == null
          ? null
          : AssetReference.fromJson(json['sound'] as Map<String, dynamic>),
      gain: (json['gain'] as num?)?.toDouble() ?? 0.7,
      keepAlive: json['keepAlive'] as bool? ?? false,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'text': instance.text,
      'sound': instance.sound,
      'gain': instance.gain,
      'keepAlive': instance.keepAlive,
    };
