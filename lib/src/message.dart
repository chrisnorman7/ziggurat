/// Provides the [Message] class.
import 'dart:io';

import 'package:meta/meta.dart';

/// A message to be output.
@immutable
class Message {
  /// Create a message.
  const Message({this.text, this.sound, this.gain = 0.7});

  /// The text of the message.
  final String? text;

  /// The sound which should be played.
  final FileSystemEntity? sound;

  /// The gain to play [sound] at.
  final double gain;
}
