/// Provides the [Message] class.
import 'package:json_annotation/json_annotation.dart';

import 'asset_reference.dart';

part 'message.g.dart';

/// A message to be output.
@JsonSerializable()
class Message {
  /// Create an instance.
  const Message({
    this.text,
    this.sound,
    this.keepAlive = false,
  });

  /// Create an instance from a JSON object.
  factory Message.fromJson(final Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  /// The text of the message.
  final String? text;

  /// The sound which should be played.
  final AssetReference? sound;

  /// Whether or not [sound] should be kept alive after playing.
  final bool keepAlive;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

/// An empty message.
///
/// This value should be used in those cases where a message is required, but
/// not used.
const emptyMessage = Message();
