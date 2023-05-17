/// Provides the [Ambiance] class.
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

import '../game.dart';
import '../json/asset_reference.dart';
import 'common.dart';

part 'ambiance.g.dart';

/// A constantly playing sound on a map.
@JsonSerializable()
class Ambiance {
  /// Create an instance.
  const Ambiance({
    required this.sound,
    this.position,
  });

  /// Create an instance from JSON.
  factory Ambiance.fromJson(final Map<String, dynamic> json) =>
      _$AmbianceFromJson(json);

  /// The sound to play.
  final AssetReference sound;

  /// The position of the [sound].
  ///
  /// If [position] is `null`, then the ambiance will not be positional, and
  /// will play through [Game.ambianceSounds].
  @JsonKey(fromJson: stringToPointDoubleNullable, toJson: pointDoubleToString)
  final Point<double>? position;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$AmbianceToJson(this);
}
