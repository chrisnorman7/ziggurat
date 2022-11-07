import 'package:json_annotation/json_annotation.dart';

import '../../ziggurat.dart';

part 'rumble_effect.g.dart';

/// A class for holding data about a rumble effect.
@JsonSerializable()
class RumbleEffect {
  /// Create an instance.
  const RumbleEffect({
    required this.duration,
    this.lowFrequency = 65535,
    this.highFrequency = 65535,
  });

  /// Create an instance from a JSON object.
  factory RumbleEffect.fromJson(final Map<String, dynamic> json) =>
      _$RumbleEffectFromJson(json);

  /// The duration of the effect.
  final int duration;

  /// The low frequency.
  final int lowFrequency;

  /// The high frequency.
  final int highFrequency;

  /// Perform this effect.
  void dispatch(final Game game) => game.rumble(
        duration: duration,
        lowFrequency: lowFrequency,
        highFrequency: highFrequency,
      );

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$RumbleEffectToJson(this);
}
