/// Provides the [RunnerSettings] class.
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'runner_settings.g.dart';

/// A function to load a file or directory from a JSON value.
FileSystemEntity? pathFromValue(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    final d = Directory(value);
    if (d.existsSync()) {
      return d;
    } else {
      return File(value);
    }
  } else {
    throw Exception('Invalid value $value.');
  }
}

/// Convert a path to a string.
String? pathToValue(FileSystemEntity? value) => value?.path;

/// Runner settings.
///
/// Instances of this class can be serialized, so that runner preferences can
/// be saved without any extra work on the part of the game developer.
@JsonSerializable()
class RunnerSettings {
  /// Create an instance.
  RunnerSettings(
      {this.wallEchoEnabled = true,
      this.maxWallFilter = 500.0,
      this.wallEchoMaxDistance = 5,
      this.wallEchoMinDelay = 0.05,
      this.wallEchoDistanceOffset = 0.01,
      this.wallEchoGain = 0.5,
      this.wallEchoGainRolloff = 0.2,
      this.wallEchoFilterFrequency = 12000});

  /// Create an instance from a JSON object.
  factory RunnerSettings.fromJson(Map<String, dynamic> json) =>
      _$RunnerSettingsFromJson(json);

  /// Whether or not an echo will be heard when walking near a wall.
  final bool wallEchoEnabled;

  /// The maximum filtering applied by walls.
  ///
  /// When sounds are filtered through walls, this value is the lowest frequency
  /// cutoff allowed.
  final double maxWallFilter;

  /// The maximum distance to play wall echoes.
  final int wallEchoMaxDistance;

  /// The minimum number of seconds before a wall echo will play.
  final double wallEchoMinDelay;

  /// A number that will be multiplied by the distance between the player and
  /// the nearest wall, and then added to [wallEchoMinDelay] to get the amount
  /// of time it will take for a wall echo to play.
  final double wallEchoDistanceOffset;

  /// The starting gain for wall echoes.
  final double wallEchoGain;

  /// The amount to reduce echo gain by over distance.
  ///
  /// The formula to decide the eventual echo gain will be
  /// `wallEchoGain - (distance * wallEchoGainRolloff)`.
  final double wallEchoGainRolloff;

  /// How much wall echoes are filtered by.
  ///
  /// Frequencies above this value will be removed from the signal.
  final double wallEchoFilterFrequency;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$RunnerSettingsToJson(this);
}
