/// Provides the [AxisSetting] class.
import 'package:dart_sdl/dart_sdl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'axis_setting.g.dart';

/// A class that specifies axis configuration.
///
/// Instances of this class are used to configure things like movement in this
/// package.
@JsonSerializable()
class AxisSetting {
  /// Create an instance.
  const AxisSetting(this.axis, this.sensitivity, this.interval);

  /// Create an instance from a JSON object.
  factory AxisSetting.fromJson(Map<String, dynamic> json) =>
      _$AxisSettingFromJson(json);

  /// The axis that this setting refers to.
  final GameControllerAxis axis;

  /// The sensitivity of [axis].
  ///
  /// Values that are less than this value will be ignored.
  final double sensitivity;

  /// How often the feature this setting configures can run.
  ///
  /// This value is given in milliseconds.
  final int interval;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$AxisSettingToJson(this);
}
