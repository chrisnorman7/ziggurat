/// Provides the [Message] class.
import 'package:json_annotation/json_annotation.dart';

import 'sound_reference.dart';

part 'message.g.dart';

/// A message to be output.
@JsonSerializable()
class Message {
  /// Create an instance.
  Message({this.text, this.sound, this.gain = 0.7});

  /// Create an instance from a JSON object.
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  /// The text of the message.
  final String? text;

  /// The sound which should be played.
  final SoundReference? sound;

  /// The gain to play [sound] at.
  final double gain;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
