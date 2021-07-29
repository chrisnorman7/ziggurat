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
      this.wallEchoFilterFrequency = 12000,
      this.directionalRadarEnabled = true,
      this.directionalRadarGain = 0.7,
      this.directionalRadarDistance = 10,
      this.directionalRadarEmptySpaceSound,
      this.directionalRadarDoorSound,
      this.directionalRadarWallSound,
      this.directionalRadarDirections = const [0, 90, 270],
      this.directionalRadarResetOnTurn = true,
      this.directionalRadarAlertOnChange = false});

  /// Create an instance from a JSON object.
  factory RunnerSettings.fromJson(Map<String, dynamic> json) =>
      _$RunnerSettingsFromJson(json);

  /// Whether or not an echo will be heard when walking near a wall.
  bool wallEchoEnabled;

  /// The maximum filtering applied by walls.
  ///
  /// When sounds are filtered through walls, this value is the lowest frequency
  /// cutoff allowed.
  double maxWallFilter;

  /// The maximum distance to play wall echoes.
  int wallEchoMaxDistance;

  /// The minimum number of seconds before a wall echo will play.
  double wallEchoMinDelay;

  /// A number that will be multiplied by the distance between the player and
  /// the nearest wall, and then added to [wallEchoMinDelay] to get the amount
  /// of time it will take for a wall echo to play.
  double wallEchoDistanceOffset;

  /// The starting gain for wall echoes.
  double wallEchoGain;

  /// The amount to reduce echo gain by over distance.
  ///
  /// The formula to decide the eventual echo gain will be
  /// `wallEchoGain - (distance * wallEchoGainRolloff)`.
  double wallEchoGainRolloff;

  /// How much wall echoes are filtered by.
  ///
  /// Frequencies above this value will be removed from the signal.
  double wallEchoFilterFrequency;

  /// Whether or not the left/right radar will be enabled.
  bool directionalRadarEnabled;

  /// The gain of left right sounds.
  double directionalRadarGain;

  /// The distance over which the left/right radar will work.
  double directionalRadarDistance;

  /// The empty space sound to use when [directionalRadarEnabled] is `true`.
  @JsonKey(fromJson: pathFromValue, toJson: pathToValue)
  FileSystemEntity? directionalRadarEmptySpaceSound;

  /// The door sound to use when [directionalRadarEnabled] is enabled.
  @JsonKey(fromJson: pathFromValue, toJson: pathToValue)
  FileSystemEntity? directionalRadarDoorSound;

  /// The wall sound to use when [directionalRadarEnabled] is `true`.
  @JsonKey(fromJson: pathFromValue, toJson: pathToValue)
  FileSystemEntity? directionalRadarWallSound;

  /// The directions to scan when [directionalRadarEnabled] is `true`.
  final List<int> directionalRadarDirections;

  /// Whether or not to reset the directional radar when turning.
  bool directionalRadarResetOnTurn;

  /// Whether the directional radar should only ping when things change.
  bool directionalRadarAlertOnChange;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$RunnerSettingsToJson(this);
}
