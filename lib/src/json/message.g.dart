// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      text: json['text'] as String?,
      sound: json['sound'] == null
          ? null
          : SoundReference.fromJson(json['sound'] as Map<String, dynamic>),
      gain: (json['gain'] as num?)?.toDouble() ?? 0.7,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'text': instance.text,
      'sound': instance.sound,
      'gain': instance.gain,
    };