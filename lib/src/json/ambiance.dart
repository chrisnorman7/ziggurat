// ignore_for_file: prefer_final_parameters
/// Provides the [Ambiance] class.
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

import '../game.dart';
import '../json/asset_reference.dart';
import 'common.dart';
import 'music.dart';

part 'ambiance.g.dart';

/// A constantly playing sound on a map.
@JsonSerializable()
class Ambiance extends Music {
  /// Create an instance.
  const Ambiance({
    required super.sound,
    super.gain,
    this.position,
  });

  /// Create an instance from JSON.
  factory Ambiance.fromJson(final Map<String, dynamic> json) =>
      _$AmbianceFromJson(json);

  /// The position of the sound.
  ///
  /// If this value is `null`, then the ambiance will not be positional, and
  /// will play through [Game.ambianceSounds].
  @JsonKey(fromJson: stringToPointDoubleNullable, toJson: pointDoubleToString)
  final Point<double>? position;

  /// Convert an instance to JSON.
  @override
  Map<String, dynamic> toJson() => _$AmbianceToJson(this);
}
