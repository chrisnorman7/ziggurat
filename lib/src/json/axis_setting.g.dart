// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'axis_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AxisSetting _$AxisSettingFromJson(Map<String, dynamic> json) => AxisSetting(
      $enumDecode(_$GameControllerAxisEnumMap, json['axis']),
      (json['sensitivity'] as num).toDouble(),
      json['interval'] as int,
    );

Map<String, dynamic> _$AxisSettingToJson(AxisSetting instance) =>
    <String, dynamic>{
      'axis': _$GameControllerAxisEnumMap[instance.axis],
      'sensitivity': instance.sensitivity,
      'interval': instance.interval,
    };

const _$GameControllerAxisEnumMap = {
  GameControllerAxis.invalid: 'invalid',
  GameControllerAxis.leftx: 'leftx',
  GameControllerAxis.lefty: 'lefty',
  GameControllerAxis.rightx: 'rightx',
  GameControllerAxis.righty: 'righty',
  GameControllerAxis.triggerleft: 'triggerleft',
  GameControllerAxis.triggerright: 'triggerright',
  GameControllerAxis.max: 'max',
};
