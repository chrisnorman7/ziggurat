import 'package:json_annotation/json_annotation.dart';

import '../levels/level.dart';
import 'asset_reference.dart';

part 'music.g.dart';

/// A class for playing music on a [Level] instance.
@JsonSerializable()
class Music {
  /// Create an instance.
  const Music({
    required this.sound,
    required this.gain,
  });

  /// Create an instance from a JSON object.
  factory Music.fromJson(Map<String, dynamic> json) => _$MusicFromJson(json);

  /// The reference to the asset.
  final AssetReference sound;

  /// The gain of the sound.
  final double gain;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$MusicToJson(this);
}
