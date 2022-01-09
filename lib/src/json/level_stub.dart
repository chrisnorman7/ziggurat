/// Provides the [LevelStub] class.
import 'package:json_annotation/json_annotation.dart';

import 'ambiance.dart';
import 'random_sound.dart';

part 'level_stub.g.dart';

/// A stub which can be used to create a basic level.
///
/// Stubs can also be used with more complimented invocations of level
/// subclasses by simply accessing the [ambiances] and [randomSounds]
/// properties.
@JsonSerializable()
class LevelStub {
  /// Create an instance.
  const LevelStub({
    this.ambiances = const [],
    this.randomSounds = const [],
  });

  /// Create an instance from JSON.
  factory LevelStub.fromJson(Map<String, dynamic> json) =>
      _$LevelStubFromJson(json);

  /// The ambiances for this stub.
  final List<Ambiance> ambiances;

  /// The random sounds for this stub.
  final List<RandomSound> randomSounds;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$LevelStubToJson(this);
}
