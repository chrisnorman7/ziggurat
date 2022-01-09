/// Provides the [RandomSound] class.
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

import '../json/asset_reference.dart';
import 'common.dart';

part 'random_sound.g.dart';

/// A random sound.
///
/// This sound will be played at a random point on a map, at a random interval.
@JsonSerializable()
class RandomSound {
  /// Create an instance.
  const RandomSound({
    required this.sound,
    required this.minCoordinates,
    required this.maxCoordinates,
    required this.minInterval,
    required this.maxInterval,
    this.minGain = 0.75,
    this.maxGain = 0.75,
  });

  /// Return an instance from JSON.
  factory RandomSound.fromJson(Map<String, dynamic> json) =>
      _$RandomSoundFromJson(json);

  /// The sound to play.
  final AssetReference sound;

  /// The minimum coordinates.
  @JsonKey(fromJson: stringToPointDouble, toJson: pointDoubleToString)
  final Point<double> minCoordinates;

  /// The maximum coordinates.
  @JsonKey(fromJson: stringToPointDouble, toJson: pointDoubleToString)
  final Point<double> maxCoordinates;

  /// The minimum number of milliseconds between this sound playing.
  final int minInterval;

  /// The maximum number of milliseconds between this sound playing.
  ///
  /// This number will be added to [minInterval] to get the final interval.
  final int maxInterval;

  /// The minimum gain.
  final double minGain;

  /// The maximum gain.
  final double maxGain;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$RandomSoundToJson(this);
}
